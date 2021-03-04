require "sinatra"
require "sinatra/reloader"  #サーバーを起動しなくても最新の状態で利用できる
require "fileutils" #sinatraが画像を保存するのに必要
require 'sinatra/cookies'
require 'pg'
require 'irb'
require 'digest' # 暗号化用
require "erb"

enable :sessions  # session変数が利用可能になる

get "/konnnitiha" do 
    return erb :layout
end



# ーーーーーーーーーーーーーー　ロ　グ　イ　ン　シ　ス　テ　ム　ーーーーーーーーーーーーーーーーーーー
# postgreSQLに接続するためのオブジェクト
client1 = PG::connect(
    :host => ENV.fetch("DB_HOST", "localhost"),
    :user => ENV.fetch("DB_USER", "tamashiro_syuta"), 
    :password => ENV.fetch("DB_PASSWORD"),
    :dbname => ENV.fetch("DB_NAME") )

client2 = PG::connect(
    :host => ENV.fetch("DB_HOST", "localhost"),
    :user => ENV.fetch("DB_USER", "tamashiro_syuta"), 
    :password => ENV.fetch("DB_PASSWORD"),
    :dbname => ENV.fetch("DB_NAME") )

    # export DB_USER="tamashiro_syuta"
    # export DB_NAME="board"
    # export DB_PASSWORD=""
    # export DB_HOST="localhost"
    



# ------ s i g n u p ---------
get "/login_signup" do
    return erb :login_signup  # /login_signupにアクセスしたら、login_signup.erbを返すよ
end

post '/login_signup' do
    # login_signup.erbから送られてきた３つ値をそれぞれ変数に入れてる(インスタンス変数を使ってないのはviewの中で使う予定がないから)
    name = params[:name].to_s
    email = params[:email].to_s
    password = params[:password].to_s
    
    # nameがnil →→→ emailとpasswordしか送られてきてない →→→ ログイン,  そうじゃない →→→ サインアップ
    if name == ""
        # ーーーーーーーログイン処理ーーーーーーーーー
        # emailとpasswordが一致するuserを探して、変数にuserに入れる
        user = client1.exec_params("SELECT * FROM users WHERE email = $1 AND password = $2 LIMIT 1",[email, Digest::SHA1.hexdigest(password)]).to_a.first   #to_aは配列（array）に変換する
        
        
        # 一致するuserが空だったらsignin.erbを、空じゃなかったらsession[:user]に一致したuserを入れて、mypageを返す
        if user.nil?
          return erb :login_signup
        else
          session[:user] = user
          return redirect '/mypage'
        end
    else
     # ーーーーーーーサインアップ処理ーーーーーーー
        # .exec_paramsはSQL文を実行するメソッド
        # $1,$2,$3には、「,」の後の配列（ここでいうname,email,password）の１、２、３番目が入るという意味
        client1.exec_params("INSERT INTO users (name, email, password) VALUES ($1, $2, $3)",[name, email, Digest::SHA1.hexdigest(password)])
        
        #上でSQLに保存したユーザーデータをuserという変数に入れる
        user = client1.exec_params("SELECT * from users WHERE email = $1 AND password = $2", [email, Digest::SHA1.hexdigest(password)]).to_a.first  #to_aは配列（array）に変換するモノ
        # user = [ {"name" => ◯◯, "email" => ◯◯, "password" => ◯◯ } ]
        
        session[:user] = user  #userのデータをsessionの中で保存している →　今後ユーザーのデータを利用する時は、session[:user]を参照すれば良い
        # puts session[:user] #  ex) {"id"=>"11", "name"=>"d", "email"=>"d@mail.com", "password"=>"d"} のように入っている
        return redirect '/mypage'  #mypageに対して画面遷移
    end
    
end

get "/mypage" do
    @name = session[:user]["name"] # 書き換える
    # mypageに渡すインスタンス変数を定義   ユーザーの投稿のデータを配列に入れる
    @user_posts = client2.exec_params("SELECT * FROM posts WHERE user_id = $1", [session[:user]["id"]]).to_a.reverse  # ログインしているユーザーの投稿のデータ
    return erb :mypage
end




# ------ s i g n o u t ---------
delete '/signout' do
    session[:user] = nil  # セッションを切る
    redirect '/login_signup'
end






#  ------------　投　稿　--------------
post "/mypage" do
# 投稿のフォームから送られてきた内容をDBに入れて、DBを参照して引っ張り出す

    # 受け取った値を変数に入れる
    title = params[:title]
    content = params[:content]

    # 画像をpublicのimagesに保存（資料の静的ファイル配信を見る）
    if !params[:img].nil? # 画像データがあれば処理を続行する
        tempfile = params[:img][:tempfile] # ファイルがアップロードされた場所
        save_to = "./public/images/#{params[:img][:filename]}" # ファイルを保存したい場所
        FileUtils.mv(tempfile, save_to) # tempfile から save_to へ移動させてる
        @img_name = params[:img][:filename]
        @img_path = "http://localhost:4567/images/" +  @img_name  # 投稿した画像へのパス
    end
    
    # exec_paramsを使ってDBに入れる
    client2.exec_params("INSERT INTO posts (user_id, title, content, img_path) VALUES ($1, $2, $3, $4)",[session[:user]["id"], title, content, @img_path])
    
    # get "/mypage" do での挙動
    @name = session[:user]["name"] # 書き換える
    @user_posts = client2.exec_params("SELECT * FROM posts WHERE user_id = $1", [session[:user]["id"]]).to_a.reverse  # ログインしているユーザーの投稿のデータ

    return erb :mypage
end