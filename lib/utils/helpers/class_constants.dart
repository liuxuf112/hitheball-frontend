class ClassConstants {
  static Map<int, String> classNames = {
    0: 'None',
    1: 'Pawn',
    2: 'Knight',
    3: 'Bishop',
    4: 'Rook',
    5: 'King',
    6: 'Queen'
  };
  static Map<String, String> classDescriptions = {
    'None': 'You do not have a class.',
    'Pawn':
        'You have no special abilities. Do your best to help your teammates achieve their goals!',
    'Knight':
        'You can go into the enemy region without being tagged. However, you are unable to pick up flags.',
    'Bishop':
        'You have a larger view radius, but a larger tag radius. Inform your teammates what you see!',
    'Rook':
        'You can see all of the enemy players at all times, however you cannot see your teammates (unless they have an enemy flag).',
    'King':
        'You cannot tag enemies, but you have a larger view and tag radius.',
    'Queen':
        'You can always see one enemy flag, but you cannot pick up that flag yourself. Let your teammates know where it is!'
  };
}
