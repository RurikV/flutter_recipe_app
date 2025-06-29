import 'package:flutter/material.dart';
import '../../models/comment.dart';

class CommentsSection extends StatefulWidget {
  final List<Comment> comments;
  final Function(String) onAddComment;

  const CommentsSection({
    super.key,
    required this.comments,
    required this.onAddComment,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  bool _isAddingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comments header
          const Text(
            'Комментарии',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 23 / 16, // line-height from design
              color: Color(0xFF165932),
            ),
          ),

          // Comments list
          if (widget.comments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: Text(
                'Нет комментариев',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF797676),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.authorName,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xFF2ECC71),
                            ),
                          ),
                          Text(
                            comment.date,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xFFC2C2C2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.text,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      if (index < widget.comments.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Divider(
                            color: Color(0xFFECECEC),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

          // Add comment button or form
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
            child: _isAddingComment
                ? Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF165932),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Оставить комментарий',
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Color(0xFFC2C2C2),
                              ),
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.image,
                                color: Color(0xFF797676),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isAddingComment = false;
                                _commentController.clear();
                              });
                            },
                            child: const Text(
                              'Отмена',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Color(0xFF797676),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_commentController.text.isNotEmpty) {
                                widget.onAddComment(_commentController.text);
                                setState(() {
                                  _isAddingComment = false;
                                  _commentController.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF165932),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              minimumSize: const Size(120, 40),
                            ),
                            child: const Text(
                              'Отправить',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isAddingComment = true;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF165932),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        minimumSize: const Size(232, 48),
                      ),
                      child: const Text(
                        'Добавить комментарий',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF165932),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}