# encoding: utf-8
class Deploy

  def self.deploy(address)
    pull_result = `git pull origin practice`
    bundle_result = `bundle`
    `RAILS_ENV=production rake assets:precompile`
    `touch tmp/restart`
    {
      pull_result: pull_result,
      bundle_result: bundle_result
    }
  end
end
