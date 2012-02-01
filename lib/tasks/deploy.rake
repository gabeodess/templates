namespace :staging do
  desc "deploy the code"
  task :deploy => ['assets', 'push', 'migrate']
    
  desc "seed staging database with default values"
  task :seed do
    puts `heroku rake db:seed --app mantisgraphics-staging`
  end
  
  desc "deploy the code to staging"
  task :push do
    puts `git push staging staging:master`
  end
  
  desc "run the migrations on the staging application"
  task :migrate do
    puts `heroku rake db:migrate --app mantisgraphics-staging`
  end
  
  desc "pull code from the staging repository to the local 'staging' branch"
  task :pull do
    puts `git pull staging master:staging`
  end
end

namespace :production do
  desc "deploy the code"
  task :deploy => ['push', 'migrate']
  
  desc "seed production database with default values"
  task :seed do
    puts `heroku rake db:seed --app mantisgraphics`
  end
    
  desc "deploy the code to production"
  task :push do
    puts `git push production master`
  end
  
  desc "run the migrations on the production application"
  task :migrate do
    puts `heroku rake db:migrate --app mantisgraphics`
  end
  
  desc "pull code from the production repository"
  task :pull do
    puts `git pull production`
  end
end

namespace :deploy do
  desc "setup the git remotes for deployment"
  task :setup do
    remotes = `git remote`.split("\n")
    puts remotes.include?('staging') ? 
      "remote 'staging' already exists" : 
      `git remote add staging git@heroku.com:mantisgraphics-staging.git`

    puts remotes.include?('production') ? 
      "remote 'production' already exists" : 
      `git remote add production git@heroku.com:mantisgraphics.git`    
  end
end