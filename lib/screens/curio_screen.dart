import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CurioScreen extends StatefulWidget {
  const CurioScreen({super.key});

  @override
  State<CurioScreen> createState() => _CurioScreenState();
}

class _CurioScreenState extends State<CurioScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GenerativeModel _model;
  bool _isLoading = false;
  bool _showScrollToBottom = false;
  bool _isConnected = true;
  
  @override
  void initState() {
    super.initState();
    _initGemini();
    _checkConnectivity();
    _removeOldMessages();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  void _scrollListener() {
    // Check if we're near the bottom
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      // Show button when scrolled up more than 200 pixels from bottom
      final threshold = 200.0;
      setState(() {
        _showScrollToBottom = maxScroll - currentScroll > threshold;
      });
    }
  }

  void _initGemini() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      print('Error: GEMINI_API_KEY not found in .env file');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing API key configuration')),
      );
      return;
    }
    
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.sexuallyExplicit,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.dangerousContent,
          HarmBlockThreshold.medium,
        ),
      ],
    );
  }

  Future<void> _removeOldMessages() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      final twentyFourHoursAgo = DateTime.now().subtract(Duration(hours: 24));
      
      final QuerySnapshot oldMessages = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chat_messages')
          .where('timestamp', isLessThan: twentyFourHoursAgo.millisecondsSinceEpoch)
          .get();
          
      for (var doc in oldMessages.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error removing old messages: $e');
      // Don't show error to user as this is a background operation
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
      return;
    }
    
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to use the chatbot')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Clear the input field
    _messageController.clear();
    
    // Generate a unique ID for this message
    final messageId = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    try {
      // Save user message to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chat_messages')
          .doc(messageId)
          .set({
            'text': text,
            'isUser': true,
            'timestamp': timestamp,
            'dateFormatted': DateFormat('MMM d, h:mm a').format(DateTime.now()),
          });
      
      // Scroll to the bottom
      _scrollToBottom();
      
      // Use Gemini API for generating a response
      final systemPrompt = '''You are Curio, a helpful and friendly assistant for parents of young children.
You ONLY provide advice on:
- Fun and educational activities for children aged 1-12
- Tips to reduce screen time and encourage outdoor play
- Simple solutions for common childhood behavioral issues
- Basic health advice for non-emergency situations
- Age-appropriate games, toys, and books

If asked about topics unrelated to children or parenting (such as data science, programming, news, politics, etc.), politely explain that you only discuss children-related topics and suggest asking a child-related question instead.

Keep responses concise (under 3 paragraphs), child-safe, and practical for busy parents.
For health concerns, always remind parents to consult healthcare professionals for medical advice.
Be warm, supportive, and non-judgmental in your tone.''';

      final chat = _model.startChat(
        history: [
          Content.text(systemPrompt),
        ],
      );
      
      final response = await chat.sendMessage(
        Content.text(text),
      );
      
      final botMessageId = const Uuid().v4();
      final botTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      if (response.text != null) {
        // Save bot response to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('chat_messages')
            .doc(botMessageId)
            .set({
              'text': response.text,
              'isUser': false,
              'timestamp': botTimestamp,
              'dateFormatted': DateFormat('MMM d, h:mm a').format(DateTime.now()),
            });
      } else {
        // Handle error case with a default message
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('chat_messages')
            .doc(botMessageId)
            .set({
              'text': "I'm sorry, I couldn't process that request. Could you try asking in a different way?",
              'isUser': false,
              'timestamp': botTimestamp,
              'dateFormatted': DateFormat('MMM d, h:mm a').format(DateTime.now()),
            });
      }
    } catch (e) {
      print('Error sending/receiving message: $e');
      
      String errorMessage = "I'm having trouble connecting right now. Please try again later.";
      
      // More specific error messages based on error type
      if (e is FirebaseException) {
        if (e.code == 'permission-denied') {
          errorMessage = "Access denied. There might be an issue with your account permissions.";
        } else if (e.code == 'unavailable') {
          errorMessage = "Firebase service is currently unavailable. Please try again later.";
        }
      }
      
      // Save error message to Firestore if possible
      try {
        final botMessageId = const Uuid().v4();
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('chat_messages')
            .doc(botMessageId)
            .set({
              'text': errorMessage,
              'isUser': false,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'dateFormatted': DateFormat('MMM d, h:mm a').format(DateTime.now()),
            });
      } catch (storeError) {
        // If we can't store the error in Firestore, just show it in the UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Use a delay to ensure the list has been built
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA873E8),
        title: Text(
          'Curio',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isConnected)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.cloud_off, color: Colors.white),
            ),
        ],
      ),
      body: user == null
          ? _buildLoginRequired()
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: _buildChatMessages(user.uid),
                    ),
                    _buildInputBar(),
                  ],
                ),
                if (_showScrollToBottom)
                  Positioned(
                    bottom: 80, // Position above input bar
                    right: 16,
                    child: _buildScrollToBottomButton(),
                  ),
              ],
            ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return FloatingActionButton(
      mini: true,
      backgroundColor: const Color(0xFFA873E8),
      onPressed: _scrollToBottom,
      child: const Icon(
        Icons.arrow_downward,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 64,
            color: Color(0xFFA873E8),
          ),
          const SizedBox(height: 16),
          Text(
            'Login Required',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA873E8),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Please login to use the Curio chatbot assistant',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen or trigger login process
              // This depends on how you've implemented authentication in your app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please return to the main screen and log in')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA873E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Go to Login',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading messages',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'There was a problem connecting to the database. This may be due to security rules or network issues.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Refresh the page
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA873E8),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildWelcomeMessage();
        }

        final messages = snapshot.data!.docs;
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(
              text: message['text'] as String,
              isUser: message['isUser'] as bool,
              timestamp: message['dateFormatted'] as String,
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFA873E8).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                size: 48,
                color: Color(0xFFA873E8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to Curio!',
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFA873E8),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Ask me anything about kids activities, reducing screen time, or parenting tips.',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSuggestionChip('Fun activities for a rainy day?'),
                  _buildSuggestionChip('How to reduce my 5-year-old\'s screen time?'),
                  _buildSuggestionChip('My 3-year-old won\'t eat vegetables'),
                  _buildSuggestionChip('Educational games for a 7-year-old'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _sendMessage(text),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF5D7BD5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF5D7BD5).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Color(0xFF5D7BD5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: const Color(0xFF5D7BD5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isUser,
    required String timestamp,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFA873E8)
              : const Color(0xFF5D7BD5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isUser 
              ? Text(
                  text,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                )
              : MarkdownBody(
                  data: text,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    strong: GoogleFonts.quicksand(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
            const SizedBox(height: 6),
            Text(
              timestamp,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: isUser
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: _isConnected,
                decoration: InputDecoration(
                  hintText: _isConnected 
                      ? 'Ask Curio something...' 
                      : 'No internet connection...',
                  hintStyle: GoogleFonts.quicksand(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: _isConnected ? Colors.grey[100] : Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.quicksand(color: Colors.black),
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_isLoading || !_isConnected) ? null : (text) => _sendMessage(text),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: (_isLoading || !_isConnected) 
                    ? Colors.grey 
                    : const Color(0xFFA873E8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: (_isLoading || !_isConnected)
                    ? null
                    : () => _sendMessage(_messageController.text),
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        _isConnected ? Icons.send_rounded : Icons.cloud_off,
                        color: Colors.white
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}