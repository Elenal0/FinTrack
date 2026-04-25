import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:spendify/config/app_color.dart';
import 'package:spendify/controller/groups_controller/group_chat_controller.dart';
import 'package:spendify/main.dart';
import 'package:spendify/model/chat_model.dart';
import 'package:spendify/model/group_model.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  
  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late final GroupChatController _ctrl;
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(GroupChatController(groupId: widget.group.id), tag: widget.group.id);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    Get.delete<GroupChatController>(tag: widget.group.id);
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textCtrl.text;
    if (text.trim().isNotEmpty) {
      _ctrl.sendMessage(text);
      _textCtrl.clear();
      // Wait a moment for stream to update then scroll
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColor.darkBg : const Color(0xFFF6F5F3);
    final textPrimary = isDark ? AppColor.textPrimary : const Color(0xFF09090B);
    final textMuted = isDark ? AppColor.textSecondary : const Color(0xFF71717A);
    final myUid = supabaseC.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsLight.caretLeft, color: textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Text(widget.group.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.group.name,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages List
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (_ctrl.messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet.\nStart the conversation!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textMuted, height: 1.5),
                  ),
                );
              }

              // Use addPostFrameCallback to scroll to bottom when new messages arrive
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _ctrl.messages.length,
                itemBuilder: (context, index) {
                  final msg = _ctrl.messages[index];
                  final isMe = msg.userId == myUid;
                  
                  // Check if previous message was from the same user to group bubbles
                  bool showName = true;
                  if (index > 0) {
                    final prevMsg = _ctrl.messages[index - 1];
                    if (prevMsg.userId == msg.userId) {
                      showName = false;
                    }
                  }

                  return _ChatBubble(
                    message: msg,
                    isMe: isMe,
                    showName: showName,
                    isDark: isDark,
                  );
                },
              );
            }),
          ),
          
          // Chat Input Field
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: isDark ? AppColor.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColor.darkBorder : const Color(0xFFEEEEEE),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColor.darkCard : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textCtrl,
                      style: TextStyle(color: textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => GestureDetector(
                  onTap: _ctrl.isSending.value ? null : _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _ctrl.isSending.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const PhosphorIcon(
                              PhosphorIconsFill.paperPlaneRight,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatModel message;
  final bool isMe;
  final bool showName;
  final bool isDark;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.showName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textMuted = isDark ? AppColor.textSecondary : const Color(0xFF71717A);
    
    // Check if it's a system message
    final isExpenseAlert = message.message.startsWith('🔔');
    final isSettlementAlert = message.message.startsWith('✅');
    final isSystemMessage = isExpenseAlert || isSettlementAlert;

    Color bubbleColor;
    Color textColor;
    
    if (isExpenseAlert) {
      bubbleColor = AppColor.expense.withValues(alpha: 0.1);
      textColor = AppColor.expense;
    } else if (isSettlementAlert) {
      bubbleColor = AppColor.income.withValues(alpha: 0.1);
      textColor = AppColor.income;
    } else {
      bubbleColor = isMe 
          ? AppColor.primary 
          : (isDark ? AppColor.darkCard : Colors.white);
      textColor = isMe ? Colors.white : (isDark ? Colors.white : Colors.black);
    }

    if (isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Center(
          child: GestureDetector(
            onTap: () {
              if (message.splitId != null) {
                Get.back(); // Return to GroupDetailScreen
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: textColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    message.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  if (message.splitId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view expense',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: showName ? 16 : 4,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName && !isMe) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.senderName ?? 'Member',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: !isMe && !isDark ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isMe ? 0 : 12,
              right: isMe ? 12 : 0,
            ),
            child: Text(
              message.formattedTime,
              style: TextStyle(
                color: textMuted,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
