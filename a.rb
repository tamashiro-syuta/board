user_posts = [{"id"=>"10", "user_id"=>"21", "title"=>"1", "content"=>"111", "img_path"=>"http://localhost:4567/images/1.png"}, 
              {"id"=>"11", "user_id"=>"21", "title"=>"2", "content"=>"222", "img_path"=>"http://localhost:4567/images/2.png"}, 
              {"id"=>"12", "user_id"=>"21", "title"=>"3", "content"=>"333", "img_path"=>"http://localhost:4567/images/3.png"}, 
              {"id"=>"13", "user_id"=>"21", "title"=>"4", "content"=>"444", "img_path"=>"http://localhost:4567/images/4.png"}, 
              {"id"=>"14", "user_id"=>"21", "title"=>"5", "content"=>"555", "img_path"=>"http://localhost:4567/images/jinon.jpeg"}
             ]

user_posts.each do |user_post|
    puts user_post["title"]
    puts user_post["content"]
end