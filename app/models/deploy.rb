# encoding: utf-8
class Deploy

  def self.deploy
    pull_result = `git pull origin deploy`
    bundle_result = `bundle`
    `RAILS_ENV=production rake assets:precompile`
    `touch tmp/restart`
    {
      pull_result: pull_result,
      bundle_result: bundle_result
    }
  end

  def self.deploy_staging
    # first copy database from production server
    `mongodump --db baby_plan_production --username db_user --password Brs@2016`
    `mongorestore --db baby_plan_staging --username db_user --password Brs@2016 --drop dump/baby_plan_production`
    pull_result = `git pull origin deploy`
    bundle_result = `bundle`
    `RAILS_ENV=production rake assets:precompile`
    `touch tmp/restart`
    {
      pull_result: pull_result,
      bundle_result: bundle_result
    }
  end

  def self.deploy_practice
    pull_result = `git pull origin practice`
    bundle_result = `bundle`
    {
      pull_result: pull_result,
      bundle_result: bundle_result
    }
  end
end
