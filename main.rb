require 'dxruby'

# Window設定
Window.caption = 'Opening'
Window.width = 960
Window.height = 640

# 音読み込み
bgm_map = Sound.new( 'map.wav' )
bgm_store = Sound.new( 'store.wav' )
bgm_hall = Sound.new( 'hall.wav' )
se_enter = Sound.new( 'enter.wav' )
bgm_map.loop_count = -1
bgm_store.loop_count = -1
bgm_hall.loop_count = -1

# 画像読み込み
image_window = Image.load( 'window.png' )
image_chara = Image.load_tiles( 'chara.png', 12, 4 )
image_chara << Image.load( 'chara_store.png' )
image_face = []
5.times do |i|
  4.times do |j|
    image_face << Image.load( "face/#{i}_#{j}.png" )
  end
end
image_map_world = Image.load( 'map_world.png' )
image_map_store = Image.load( 'map_store.png' )
image_map_hall = Image.load( 'map_hall.png' )
image_fade = Image.new( Window.width, Window.height, C_BLACK )
image_fade.box_fill( 0, 0, Window.width, Window.height, C_BLACK )

# セリフ読み込み
speech = []
File.open( 'speech.txt' ) do |file|
  file.readlines.each do |line|
    speech << line.chomp
  end
end
speech.insert( 4, speech.slice!( 4, 2 ).join("\n") )
speech.insert( 9, speech.slice!( 9, 3 ).join("\n") )
speech.insert( 25, speech.slice!( 25, 2 ).join("\n") )
speech.insert( 26, speech.slice!( 26, 2 ).join("\n") )
speech_chara = []
File.open( 'speech_chara.txt' ) do |file|
  file.readlines.each do |line|
    speech_chara << line.chomp.to_i
  end
end
p "SPEECH FILE ERROR!" unless speech.length == speech_chara.length

# 変数
name1_exist = 0
name2_exist = 0
name_x = (Window.width-image_window.width/2)/2+50
name_y = 30
speech_x = 70
speech_y = Window.height-image_window.height+20
font_32 = Font.new(32, "Terminal")
font_24 = Font.new(24, "Terminal")
count = 0
speech_count = 0
speech_time = 0
walk_count = 0
walk_d = 1
chara_x = []
chara_y = []
chara_dir = []
4.times do |i|
  chara_x << 80 + i*32
  chara_y << 550
  chara_dir << 0
end
chara_speed = 1
map_num = 0
in_flag = 0
exit_flag = 0
fade_count = 255

Window.loop do

  # 入力
  if Input.key_push?( K_I )
    bgm_map.play
    in_flag = 1
  end
  if Input.key_push?( K_Q )
    exit_flag = 1
  end
  if Input.key_push?( K_M )
    se_enter.play
    chara_speed = 1
    map_num += 1
    map_num = 0 if map_num > 5
    4.times do |i|
      case map_num
      when 0 # ワールドマップ
        bgm_store.stop
        bgm_hall.stop
        bgm_map.play
        chara_x[i] = 80 + i*32
        chara_y[i] = 550
        chara_dir[i] = 2
      when 1,3 # 楽器屋
        bgm_map.stop
        bgm_hall.stop
        bgm_store.play
        chara_x[i] = 400 + i*32
        chara_y[i] = 550
        chara_dir[i] = 0
      when 2 # ワールドマップ
        bgm_store.stop
        bgm_hall.stop
        bgm_map.play
        name1_exist = 0
        chara_x[i] = 80 + i*32
        chara_y[i] = 550
        chara_dir[i] = 0
      when 4 # ワールドマップ
        bgm_store.stop
        bgm_hall.stop
        bgm_map.play
        chara_x[i] = 210 + i*32
        chara_y[i] = 150
        chara_dir[i] = 2
      when 5 # 県民会館
        bgm_map.stop
        bgm_store.stop
        bgm_hall.play
        chara_x[i] = 430 + i*32
        chara_y[i] = 360
        chara_dir[i] = 0
      end
    end
  end
  if Input.key_push?( K_LSHIFT )
    if name1_exist == 0
      name1_exist = 1
    elsif name1_exist == 1
      name1_exist = 0
    end
  end
  if Input.key_push?( K_RSHIFT )
    if name2_exist == 0
      name2_exist = 1
    elsif name2_exist == 1
      name2_exist = 0
    end
  end
  if Input.key_push?( K_SPACE )
    speech_time = 1
    speech_count += 1
    speech_count = 0 if speech_count > speech.length
  end
  if Input.key_push?( K_Z )
    4.times{ |i| chara_dir[i] = 2 }
  end
  if Input.key_push?( K_1 )
    chara_speed = 1
  end
  if Input.key_push?( K_2 )
    chara_speed = 2
  end
  if Input.key_down?( K_UP )
    4.times do |i|
      chara_dir[i] = 0
      chara_y[i] -= chara_speed
    end
  end
  if Input.key_down?( K_DOWN )
    name1_exist = 0
    4.times do |i|
      chara_dir[i] = 2
      chara_y[i] += chara_speed
    end
  end
  if Input.key_down?( K_LEFT )
    4.times do |i|
      chara_dir[i] = 3
      chara_x[i] -= chara_speed
    end
  end
  if Input.key_down?( K_RIGHT )
    4.times do |i|
      chara_dir[i] = 1
      chara_x[i] += chara_speed
    end
  end
  
  # 描画
  case map_num
  when 0,2,4 # ワールドマップ
    Window.draw( 0, 0, image_map_world )
    Window.draw_scale( (Window.width-image_window.width)/2, -30, image_window, 0.5, 0.5 ) if name1_exist == 1 || name2_exist == 1
    Window.draw_font( name_x+16, name_y, "楽器屋", font_32 ) if name1_exist == 1
    Window.draw_font( name_x, name_y, "県民会館", font_32 ) if name2_exist == 1
  when 1,3 # 楽器屋
    Window.draw( 0, 0, image_map_store )
    Window.draw( 9*32, 15+5*32, image_chara[-1] )
  when 5 # 県民会館
    Window.draw( 0, 0, image_map_hall )
  end
  Window.draw_scale( (Window.width-image_window.width)/2, Window.height-image_window.height, image_window, 1.8, 1.1 ) if speech_time > 0
  Window.draw( speech_x, speech_y+30, image_face[speech_chara[speech_count-1]] ) if speech_time > 0 && speech_chara[speech_count-1] < 20
  4.times{ |i| Window.draw( speech_x+i*image_face[4*i-1].width+10*i, speech_y+30, image_face[4*i+3] ) } if speech_time > 0 && speech_count == 22
  Window.draw_font( speech_x, speech_y, speech[speech_count-1], font_24 ) if speech_time > 0
  4.times{ |i| Window.draw_scale( chara_x[i], chara_y[i], image_chara[3*i+12*chara_dir[i]+walk_count], 1.5, 1.5 ) }
  
  # フェードイン
  Window.draw_alpha( 0, 0, image_fade, fade_count.to_i, 999 )
  if in_flag == 1
    fade_count -= 1 if fade_count > 0
    in_flag = 0 if fade_count == 0
  end
  
  # フェードアウト
  if exit_flag == 1
    bgm_map.set_volume( 0, 1000 )
    bgm_store.set_volume( 0, 1000 )
    bgm_hall.set_volume( 0, 1000 )
    if fade_count > 250
      bgm_map.stop
      bgm_store.stop
      bgm_hall.stop
    end
    Window.draw_alpha( 0, 0, image_fade, fade_count.to_i, 999 )
    fade_count += 1 if fade_count < 255
    exit_flag = 0 if fade_count == 255
  end
  
  # 終了
  break if Input.key_push?( K_ESCAPE )
  
  # カウント
  count += 1
  count = 0 if count > 1000
  if count % 20 == 0
    walk_count += walk_d
    walk_d = -walk_d if walk_count == 0 || walk_count == 2
  end
  if speech_time > 0
    speech_time += 1
    speech_time = 0 if speech_time > 200
  end
  
end
