import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendify/main.dart';
import 'package:spendify/model/chat_model.dart';
import 'package:spendify/widgets/toast/custom_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupChatController extends GetxController {
  final String groupId;
  GroupChatController({required this.groupId});

  var messages = <ChatModel>[].obs;
  var isLoading = true.obs;
  var isSending = false.obs;

  late RealtimeChannel _channel;
  StreamSubscription? _messagesSubscription;

  // Cache display names to avoid redundant queries
  final Map<String, String> _nameCache = {};

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    supabaseC.removeChannel(_channel);
    super.onClose();
  }

  void _listenToMessages() {
    isLoading.value = true;
    
    // Listen to changes in the group_chats table via Realtime Stream
    _messagesSubscription = supabaseC
        .from('group_chats')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: true) // oldest first, UI will scroll to bottom
        .listen((List<Map<String, dynamic>> data) async {
          
      final List<ChatModel> parsedMessages = [];
      
      for (var row in data) {
        final userId = row['user_id'] as String;
        final senderName = await _getUserName(userId);
        parsedMessages.add(ChatModel.fromMap(row, senderName: senderName));
      }
      
      messages.value = parsedMessages;
      isLoading.value = false;
    }, onError: (error) {
      debugPrint('Error in chat stream: $error');
      isLoading.value = false;
    });
  }

  Future<String> _getUserName(String userId) async {
    if (_nameCache.containsKey(userId)) {
      return _nameCache[userId]!;
    }
    
    // If it's me, just say "You" or return my name. I'll just fetch from DB to be consistent.
    try {
      final res = await supabaseC
          .from('users')
          .select('name')
          .eq('id', userId)
          .maybeSingle();
      final name = (res?['name'] as String?) ?? 'Member';
      _nameCache[userId] = name;
      return name;
    } catch (_) {
      return 'Member';
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final uid = supabaseC.auth.currentUser?.id;
    if (uid == null) return;

    isSending.value = true;
    try {
      await supabaseC.from('group_chats').insert({
        'group_id': groupId,
        'user_id': uid,
        'message': text.trim(),
      });
      // The stream will automatically receive the new message and update the UI!
    } catch (e) {
      debugPrint('Error sending message: $e');
      CustomToast.errorToast('Error', 'Failed to send message');
    } finally {
      isSending.value = false;
    }
  }
}
