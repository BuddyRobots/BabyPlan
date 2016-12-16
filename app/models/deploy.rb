# encoding: utf-8
class Deploy

  def self.deploy(address)
    `cd ~#{address}`
    pull_result = `git pull origin practice`
    bundle_result = `bundle`
    compile_result = `RAILS_ENV=production rake assets:precompile`
    `touch tmp/restart`
    {
      pull_result: pull_result,
      bundle_result: bundle_result,
      compile_result: compile_result
    }
  end
end
