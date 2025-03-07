class Reaction {
  final String emoji;
  final String userId;

  Reaction({required this.emoji, required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'emoji': emoji,
      'userId': userId,
    };
  }

  factory Reaction.fromMap(Map<String, dynamic> map) {
    return Reaction(
      emoji: map['emoji'],
      userId: map['userId'],
    );
  }
}