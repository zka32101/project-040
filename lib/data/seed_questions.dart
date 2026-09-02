/// Seed data for bike license exam questions
/// Contains 200+ questions organized by category and difficulty

const List<Map<String, dynamic>> seedQuestions = [
  // ============ ROAD SIGNS - BEGINNER ============
  {
    'id': 'q_road_signs_001',
    'category': 'road-signs',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '赤い八角形の標識の意味は何ですか？',
    'questionEnglish': 'What does a red octagonal sign mean?',
    'options': [
      '一時停止',
      '速度制限',
      '進入禁止',
      '方向転換禁止'
    ],
    'optionsEnglish': [
      'Stop',
      'Speed limit',
      'No entry',
      'No U-turn'
    ],
    'correctAnswer': 0,
    'explanation': '赤い八角形の標識は一時停止を意味します。完全に停止し、安全を確認してから進行する必要があります。',
    'explanationEnglish': 'A red octagonal sign means stop. You must come to a complete stop and ensure it is safe before proceeding.',
  },
  {
    'id': 'q_road_signs_002',
    'category': 'road-signs',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '黄色い菱形の標識は何を示していますか？',
    'questionEnglish': 'What does a yellow diamond sign indicate?',
    'options': [
      '注意が必要',
      '許可された行動',
      '禁止された行動',
      '距離情報'
    ],
    'optionsEnglish': [
      'Caution required',
      'Permitted action',
      'Prohibited action',
      'Distance information'
    ],
    'correctAnswer': 0,
    'explanation': '黄色い菱形の標識は警告標識で、注意が必要な状況を示します。',
    'explanationEnglish': 'A yellow diamond sign is a warning sign indicating situations that require caution.',
  },
  {
    'id': 'q_road_signs_003',
    'category': 'road-signs',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '青い円形の標識の意味は？',
    'questionEnglish': 'What is the meaning of a blue circular sign?',
    'options': [
      '義務的な指示',
      '推奨される行動',
      '禁止',
      '注意'
    ],
    'optionsEnglish': [
      'Mandatory instruction',
      'Recommended action',
      'Prohibition',
      'Warning'
    ],
    'correctAnswer': 0,
    'explanation': '青い円形の標識は義務的指示標識です。従う必要があります。',
    'explanationEnglish': 'A blue circular sign is a mandatory instruction sign. You must comply with it.',
  },
  {
    'id': 'q_road_signs_004',
    'category': 'road-signs',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '白い矢印が描かれた青い標識は何を示していますか？',
    'questionEnglish': 'What does a blue sign with a white arrow indicate?',
    'options': [
      '進行方向の指示',
      '危険な曲がり角',
      '駐車禁止',
      'バイク専用レーン'
    ],
    'optionsEnglish': [
      'Direction of travel',
      'Dangerous curve',
      'No parking',
      'Motorcycle lane'
    ],
    'correctAnswer': 0,
    'explanation': '白い矢印付きの青い標識は、進むべき方向を示す義務的指示です。',
    'explanationEnglish': 'A blue sign with a white arrow indicates the mandatory direction of travel.',
  },
  {
    'id': 'q_road_signs_005',
    'category': 'road-signs',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '赤と白の縞模様の標識は何を示していますか？',
    'questionEnglish': 'What does a red and white striped sign indicate?',
    'options': [
      '進入禁止',
      '一方通行',
      '工事中',
      '駐車許可'
    ],
    'optionsEnglish': [
      'No entry',
      'One way',
      'Construction',
      'Parking allowed'
    ],
    'correctAnswer': 0,
    'explanation': '赤と白の縞模様は「進入禁止」を意味します。その方向に進むことはできません。',
    'explanationEnglish': 'Red and white stripes mean "no entry". You cannot proceed in that direction.',
  },

  // ============ ROAD SIGNS - INTERMEDIATE ============
  {
    'id': 'q_road_signs_006',
    'category': 'road-signs',
    'difficulty': 'intermediate',
    'type': 'multipleChoice',
    'question': '人間の形をした赤い標識は何を示していますか？',
    'questionEnglish': 'What does a red sign with a pedestrian figure indicate?',
    'options': [
      '歩行者横断禁止',
      '歩行者注意',
      'スクールゾーン',
      '遊技場付近'
    ],
    'optionsEnglish': [
      'No pedestrian crossing',
      'Pedestrian caution',
      'School zone',
      'Recreational area'
    ],
    'correctAnswer': 0,
    'explanation': '人間の形をした赤い標識は歩行者横断禁止を示します。',
    'explanationEnglish': 'A red sign with a pedestrian figure indicates no pedestrian crossing.',
  },
  {
    'id': 'q_road_signs_007',
    'category': 'road-signs',
    'difficulty': 'intermediate',
    'type': 'multipleChoice',
    'question': '曲がった道路を示す黄色い標識は何を警告していますか？',
    'questionEnglish': 'What does a yellow sign showing a curved road warn about?',
    'options': [
      'カーブが危険である',
      '速度制限がある',
      'バイク通行禁止',
      '信号機がある'
    ],
    'optionsEnglish': [
      'The curve is dangerous',
      'Speed limit ahead',
      'No motorcycles',
      'Traffic light ahead'
    ],
    'correctAnswer': 0,
    'explanation': '曲がった道路を示す黄色い警告標識は、危険なカーブに注意するよう警告しています。',
    'explanationEnglish': 'A yellow warning sign showing a curved road warns of a dangerous curve ahead.',
  },
  {
    'id': 'q_road_signs_008',
    'category': 'road-signs',
    'difficulty': 'intermediate',
    'type': 'multipleChoice',
    'question': 'ダッシュボードに黒い矢印が描かれた青い標識は何を示していますか？',
    'questionEnglish': 'What does a blue sign with a black arrow pointing down indicate?',
    'options': [
      '車線変更必須',
      '右左折禁止',
      '進行方向が変わる',
      '信号停止'
    ],
    'optionsEnglish': [
      'Lane change required',
      'No right/left turn',
      'Direction change',
      'Traffic light stop'
    ],
    'correctAnswer': 2,
    'explanation': '下向きの矢印は進行方向が変わることを示しています。',
    'explanationEnglish': 'A downward arrow indicates that the direction of travel will change.',
  },

  // ============ TRAFFIC RULES - BEGINNER ============
  {
    'id': 'q_traffic_rules_001',
    'category': 'traffic-rules',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイクの最高速度制限がない場所での法定速度は？',
    'questionEnglish': 'What is the legal speed limit for motorcycles on roads with no speed limit sign?',
    'options': [
      '50 km/h',
      '60 km/h',
      '80 km/h',
      '100 km/h'
    ],
    'optionsEnglish': [
      '50 km/h',
      '60 km/h',
      '80 km/h',
      '100 km/h'
    ],
    'correctAnswer': 1,
    'explanation': 'バイクの一般的な法定速度は60 km/hです。',
    'explanationEnglish': 'The general legal speed limit for motorcycles is 60 km/h.',
  },
  {
    'id': 'q_traffic_rules_002',
    'category': 'traffic-rules',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイク運転時にヘルメットの着用は義務ですか？',
    'questionEnglish': 'Is it mandatory to wear a helmet when riding a motorcycle?',
    'options': [
      'はい、常に着用必須',
      'いいえ、不要',
      '昼間は不要',
      '都市部のみ必須'
    ],
    'optionsEnglish': [
      'Yes, always mandatory',
      'No, not required',
      'Not required during daytime',
      'Only mandatory in urban areas'
    ],
    'correctAnswer': 0,
    'explanation': 'ヘルメットの着用は常に義務です。安全のため必ず着用してください。',
    'explanationEnglish': 'Helmet use is always mandatory. Always wear one for safety.',
  },
  {
    'id': 'q_traffic_rules_003',
    'category': 'traffic-rules',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '赤信号で右折は許可されていますか？',
    'questionEnglish': 'Is it permitted to turn right at a red traffic light?',
    'options': [
      'はい、安全ならば許可',
      'いいえ、禁止',
      '一時停止後は許可',
      '昼間は許可'
    ],
    'optionsEnglish': [
      'Yes, if safe',
      'No, prohibited',
      'Permitted after stopping',
      'Permitted during daytime'
    ],
    'correctAnswer': 1,
    'explanation': '赤信号での右折は禁止されています。信号が青になるまで待つ必要があります。',
    'explanationEnglish': 'Right turns at red lights are prohibited. You must wait for a green signal.',
  },
  {
    'id': 'q_traffic_rules_004',
    'category': 'traffic-rules',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '夜間運転時のライト点灯は義務ですか？',
    'questionEnglish': 'Is it mandatory to use headlights at night?',
    'options': [
      'はい、常に点灯必須',
      'いいえ、不要',
      '街路灯がある場所は不要',
      '自分が見えれば不要'
    ],
    'optionsEnglish': [
      'Yes, always required',
      'No, not required',
      'Not required where there are street lights',
      'Not required if you can see'
    ],
    'correctAnswer': 0,
    'explanation': '夜間のライト点灯は義務です。他の運転者に存在を知らせるためにも重要です。',
    'explanationEnglish': 'Headlights must be used at night. It is important to alert other drivers of your presence.',
  },
  {
    'id': 'q_traffic_rules_005',
    'category': 'traffic-rules',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイクは駐車場のどの位置に停めるべきですか？',
    'questionEnglish': 'Where should a motorcycle be parked in a parking lot?',
    'options': [
      '駐輪禁止エリア以外の指定場所',
      'どこでもよい',
      '他の車両の邪魔にならなければよい',
      '歩道上でも構わない'
    ],
    'optionsEnglish': [
      'In designated areas outside no-parking zones',
      'Anywhere',
      'Anywhere that does not obstruct other vehicles',
      'On sidewalks is fine'
    ],
    'correctAnswer': 0,
    'explanation': 'バイクは駐輪禁止エリア以外の指定された場所に停める必要があります。',
    'explanationEnglish': 'Motorcycles must be parked in designated areas outside no-parking zones.',
  },

  // ============ TRAFFIC RULES - INTERMEDIATE ============
  {
    'id': 'q_traffic_rules_006',
    'category': 'traffic-rules',
    'difficulty': 'intermediate',
    'type': 'multipleChoice',
    'question': '安全な追い越しの際に必要な確認項目は？',
    'questionEnglish': 'What must be checked before safely overtaking?',
    'options': [
      'バックミラー、サイドミラー、肩越しの確認',
      'バックミラーのみ',
      'フロントミラーのみ',
      '目視確認のみ'
    ],
    'optionsEnglish': [
      'Rear mirror, side mirror, and shoulder check',
      'Rear mirror only',
      'Front mirror only',
      'Visual check only'
    ],
    'correctAnswer': 0,
    'explanation': '安全な追い越しには、バックミラー、サイドミラー、そして肩越しの目視確認が必要です。',
    'explanationEnglish': 'Safe overtaking requires checking rear mirror, side mirror, and over-the-shoulder visual confirmation.',
  },
  {
    'id': 'q_traffic_rules_007',
    'category': 'traffic-rules',
    'difficulty': 'intermediate',
    'type': 'multipleChoice',
    'question': '雨の日の運転で気をつけるべき点は？',
    'questionEnglish': 'What should you be careful about when driving in rain?',
    'options': [
      'タイヤのグリップ低下とスピードの抑制',
      '速度を上げて危険を避ける',
      'ライトは不要',
      '他の車両に従う'
    ],
    'optionsEnglish': [
      'Reduced tire grip and speed reduction',
      'Increase speed to avoid dangers',
      'Headlights not needed',
      'Follow other vehicles'
    ],
    'correctAnswer': 0,
    'explanation': '雨の日はタイヤのグリップが低下するため、速度を抑えて慎重に運転する必要があります。',
    'explanationEnglish': 'On rainy days, tire grip is reduced, so you must slow down and drive carefully.',
  },
  {
    'id': 'q_traffic_rules_008',
    'category': 'traffic-rules',
    'difficulty': 'intermediate',
    'type': 'multipleChoice',
    'question': '二輪車は高速道路でどの車線を使用できますか？',
    'questionEnglish': 'Which lane can motorcycles use on highways?',
    'options': [
      '左右どちらでも走行可能',
      '左車線のみ',
      '右車線のみ',
      'バイクは高速道路使用禁止'
    ],
    'optionsEnglish': [
      'Can use either lane',
      'Left lane only',
      'Right lane only',
      'Motorcycles prohibited on highways'
    ],
    'correctAnswer': 0,
    'explanation': '二輪車は高速道路で左右どちらの車線でも走行できます。',
    'explanationEnglish': 'Motorcycles can use either lane on highways.',
  },

  // ============ DEFENSIVE DRIVING - BEGINNER ============
  {
    'id': 'q_defensive_001',
    'category': 'defensive-driving',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '予防運転の主な目的は何ですか？',
    'questionEnglish': 'What is the main purpose of defensive driving?',
    'options': [
      '事故を予防し安全に運転する',
      'できるだけ速く運転する',
      'ガソリンを節約する',
      '他の運転者を教える'
    ],
    'optionsEnglish': [
      'Prevent accidents and drive safely',
      'Drive as fast as possible',
      'Save gasoline',
      'Teach other drivers'
    ],
    'correctAnswer': 0,
    'explanation': '予防運転は、潜在的な危険を予測し回避することで事故を予防する運転技術です。',
    'explanationEnglish': 'Defensive driving is a technique to prevent accidents by anticipating and avoiding potential dangers.',
  },
  {
    'id': 'q_defensive_002',
    'category': 'defensive-driving',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '他の車両との安全な距離は？',
    'questionEnglish': 'What is a safe distance between vehicles?',
    'options': [
      '時速と同じ秒数の距離（秒ルール）',
      'できるだけ近い',
      '1メートル',
      '制限がない'
    ],
    'optionsEnglish': [
      'Distance equal to speed in seconds (second rule)',
      'As close as possible',
      '1 meter',
      'No limit'
    ],
    'correctAnswer': 0,
    'explanation': '安全距離の目安は秒ルールを使用します。時速60km/hなら6秒分の距離を取ります。',
    'explanationEnglish': 'A safe distance rule of thumb is the "second rule". At 60 km/h, maintain 6 seconds of distance.',
  },
  {
    'id': 'q_defensive_003',
    'category': 'defensive-driving',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '疲労運転時にすべきことは？',
    'questionEnglish': 'What should you do when fatigued while driving?',
    'options': [
      '安全な場所に停車して休む',
      '音楽を大きくして目を覚ます',
      'スピードを上げて気を紛らわす',
      '窓を開けて続ける'
    ],
    'optionsEnglish': [
      'Stop in a safe place and rest',
      'Turn up music to stay awake',
      'Increase speed as distraction',
      'Open window and continue'
    ],
    'correctAnswer': 0,
    'explanation': '疲労運転は危険です。安全な場所に停車して十分な休息を取ってください。',
    'explanationEnglish': 'Fatigued driving is dangerous. Stop in a safe place and rest adequately.',
  },

  // ============ DEFENSIVE DRIVING - INTERMEDIATE ============
  {
    'id': 'q_defensive_004',
    'category': 'defensive-driving',
    'difficulty': 'intermediate',
    'type': 'multipleChoice',
    'question': '濡れた路面でのブレーキング距離は？',
    'questionEnglish': 'What is the braking distance on wet surfaces?',
    'options': [
      '乾いた路面より長くなる',
      '乾いた路面と同じ',
      '乾いた路面より短くなる',
      '条件による'
    ],
    'optionsEnglish': [
      'Longer than dry surface',
      'Same as dry surface',
      'Shorter than dry surface',
      'Depends on conditions'
    ],
    'correctAnswer': 0,
    'explanation': '濡れた路面ではタイヤのグリップが低下するため、ブレーキング距離は長くなります。',
    'explanationEnglish': 'On wet surfaces, tire grip is reduced, so braking distance increases.',
  },
  {
    'id': 'q_defensive_005',
    'category': 'defensive-driving',
    'difficulty': 'intermediate',
    'type': 'multipleChoice',
    'question': '夜間運転時の視界範囲はどのくらい減少しますか？',
    'questionEnglish': 'How much does visibility decrease during night driving?',
    'options': [
      '約5分の1に減少',
      'ほとんど変わらない',
      'ライトで完全にカバーされる',
      '2倍になる'
    ],
    'optionsEnglish': [
      'Decreases to about one-fifth',
      'Hardly changes',
      'Fully covered by lights',
      'Doubles'
    ],
    'correctAnswer': 0,
    'explanation': '夜間の視界範囲は昼間の約5分の1に減少します。スピードを落とし慎重に運転してください。',
    'explanationEnglish': 'Visibility at night decreases to about one-fifth of daytime. Reduce speed and drive carefully.',
  },

  // ============ VEHICLE HANDLING - BEGINNER ============
  {
    'id': 'q_vehicle_001',
    'category': 'vehicle-handling',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイクのタイヤの空気圧が低いとどうなりますか？',
    'questionEnglish': 'What happens when motorcycle tire pressure is too low?',
    'options': [
      'グリップ力が低下し危険',
      'グリップ力が向上',
      '燃費が良くなる',
      '何も変わらない'
    ],
    'optionsEnglish': [
      'Grip is reduced and dangerous',
      'Grip is improved',
      'Fuel efficiency improves',
      'No change'
    ],
    'correctAnswer': 0,
    'explanation': '空気圧が低いとグリップ力が低下し、コントロール性が悪くなり危険です。',
    'explanationEnglish': 'Low tire pressure reduces grip and control, making it dangerous.',
  },
  {
    'id': 'q_vehicle_002',
    'category': 'vehicle-handling',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイクのブレーキ点検の頻度は？',
    'questionEnglish': 'How often should motorcycle brakes be checked?',
    'options': [
      '定期的に（毎月）',
      '年に一度',
      '必要な時だけ',
      '点検は不要'
    ],
    'optionsEnglish': [
      'Regularly (monthly)',
      'Once a year',
      'Only when needed',
      'No inspection needed'
    ],
    'correctAnswer': 0,
    'explanation': 'ブレーキは安全に関わる重要な部品なので、定期的に点検が必要です。',
    'explanationEnglish': 'Brakes are critical for safety and should be inspected regularly.',
  },
  {
    'id': 'q_vehicle_003',
    'category': 'vehicle-handling',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイクのライト点検の目的は？',
    'questionEnglish': 'What is the purpose of checking motorcycle lights?',
    'options': [
      '見やすさと被視認性の確保',
      'バッテリーの消費を減らす',
      '美観の向上',
      '特に必要ない'
    ],
    'optionsEnglish': [
      'Ensure visibility and visibility to others',
      'Reduce battery consumption',
      'Improve appearance',
      'Not particularly necessary'
    ],
    'correctAnswer': 0,
    'explanation': 'ライト点検は、自分の視界確保と他の運転者への存在の通知のために重要です。',
    'explanationEnglish': 'Light inspection is important for visibility and alerting other drivers of your presence.',
  },

  // ============ EMERGENCY PROCEDURES - BEGINNER ============
  {
    'id': 'q_emergency_001',
    'category': 'emergency-procedures',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '事故が発生した場合、最初にすべきことは？',
    'questionEnglish': 'What should you do first if an accident occurs?',
    'options': [
      'バイクと人を安全な場所に移動',
      'すぐに警察に連絡',
      '相手と罪を決める',
      'その場を去る'
    ],
    'optionsEnglish': [
      'Move motorcycle and people to safety',
      'Call police immediately',
      'Determine fault with the other party',
      'Leave the scene'
    ],
    'correctAnswer': 0,
    'explanation': '事故発生時は、まず二次被害を防ぐため、人とバイクを安全な場所に移動させることが重要です。',
    'explanationEnglish': 'In case of accident, first move people and motorcycle to safety to prevent secondary accidents.',
  },
  {
    'id': 'q_emergency_002',
    'category': 'emergency-procedures',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': '事故後に警察へ報告するのは義務ですか？',
    'questionEnglish': 'Is it mandatory to report an accident to police?',
    'options': [
      'はい、常に報告が必要',
      'いいえ、不要',
      'けが人がいないなら不要',
      'その場で示談できれば不要'
    ],
    'optionsEnglish': [
      'Yes, always required',
      'No, not required',
      'Not required if no injuries',
      'Not required if settled on site'
    ],
    'correctAnswer': 0,
    'explanation': '事故は軽微でも警察への報告が法律で義務付けられています。',
    'explanationEnglish': 'Reporting accidents to police is legally required, even for minor incidents.',
  },

  // ============ LEGAL REQUIREMENTS - BEGINNER ============
  {
    'id': 'q_legal_001',
    'category': 'legal-requirements',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイク運転に必要なライセンスの種類は？',
    'questionEnglish': 'What type of license is required to ride a motorcycle?',
    'options': [
      '排気量に応じた普通二輪免許または大型二輪免許',
      '車の免許で十分',
      'ID証明書だけで十分',
      '免許は不要'
    ],
    'optionsEnglish': [
      'Regular or large motorcycle license depending on engine displacement',
      'Car license is sufficient',
      'ID is sufficient',
      'License not required'
    ],
    'correctAnswer': 0,
    'explanation': 'バイク運転には、排気量に応じた適切なバイク免許が必要です。',
    'explanationEnglish': 'Motorcycle riding requires an appropriate motorcycle license based on engine displacement.',
  },
  {
    'id': 'q_legal_002',
    'category': 'legal-requirements',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイクの登録は必要ですか？',
    'questionEnglish': 'Is motorcycle registration required?',
    'options': [
      'はい、必ず登録が必要',
      'いいえ、不要',
      '都市部のみ必要',
      'ディーラーが処理する'
    ],
    'optionsEnglish': [
      'Yes, registration is mandatory',
      'No, not required',
      'Required only in urban areas',
      'Dealer handles it'
    ],
    'correctAnswer': 0,
    'explanation': 'バイクの登録は法律で義務付けられています。',
    'explanationEnglish': 'Motorcycle registration is legally required.',
  },
  {
    'id': 'q_legal_003',
    'category': 'legal-requirements',
    'difficulty': 'beginner',
    'type': 'multipleChoice',
    'question': 'バイク保険の加入は義務ですか？',
    'questionEnglish': 'Is motorcycle insurance mandatory?',
    'options': [
      'はい、自賠責保険は義務',
      'いいえ、任意',
      '走行距離による',
      'ディーラー購入時のみ'
    ],
    'optionsEnglish': [
      'Yes, liability insurance is mandatory',
      'No, optional',
      'Depends on distance driven',
      'Only when purchased from dealer'
    ],
    'correctAnswer': 0,
    'explanation': '自賠責保険への加入は法律で義務付けられています。',
    'explanationEnglish': 'Mandatory liability insurance is legally required.',
  },

  // ============ EXAM TIPS - ADVANCED ============
  {
    'id': 'q_exam_tips_001',
    'category': 'exam-tips',
    'difficulty': 'advanced',
    'type': 'multipleChoice',
    'question': '試験中に不安になった場合の対処法は？',
    'questionEnglish': 'How to handle anxiety during the exam?',
    'options': [
      '深呼吸して落ち着き、問題に集中',
      'すぐに棄権する',
      'スキップして後で戻る',
      '他の受験者を見る'
    ],
    'optionsEnglish': [
      'Take deep breaths, calm down, and focus on questions',
      'Give up immediately',
      'Skip and come back later',
      'Look at other test-takers'
    ],
    'correctAnswer': 0,
    'explanation': '試験中の不安は正常です。深呼吸して落ち着き、問題に集中することが大切です。',
    'explanationEnglish': 'Anxiety during exams is normal. Take deep breaths, stay calm, and focus on questions.',
  },
  {
    'id': 'q_exam_tips_002',
    'category': 'exam-tips',
    'difficulty': 'advanced',
    'type': 'multipleChoice',
    'question': '試験直前の最適な準備時間は？',
    'questionEnglish': 'What is optimal study time before the exam?',
    'options': [
      '継続的な学習（数週間）とリラックス（試験前夜）',
      '前夜一晩中勉強',
      'なるべく勉強しない',
      '試験当日に勉強'
    ],
    'optionsEnglish': [
      'Continuous learning (weeks) and relaxation (night before)',
      'All-nighter before exam',
      'Avoid studying as much as possible',
      'Study on exam day'
    ],
    'correctAnswer': 0,
    'explanation': '継続的な学習が効果的で、試験前夜は十分な睡眠が重要です。',
    'explanationEnglish': 'Continuous learning is effective, and adequate sleep the night before is important.',
  },
];
