#!/usr/bin/env ruby

# cloned from https://gist.github.com/1203851
class Cap < Thor
  desc "commit [HEAD]", "cap deploy:upload files from one or more commits"
  method_options 'no-restart' => :boolean, 'environment' => :optional, 
                'working' => :optional, 'stage' => :optional
      
  
  def commit(refspec = 'HEAD')
    if options['working']
      diffmode = true
      refspec = String === options['working'] ? (' -- ' + options['working']) : ''
    else
      diffmode = refspec.index('..')
    end
    msg = sha = nil
    
    log_cmd =  diffmode ? 'git diff' : "git show --pretty=format:'%h %s'"
    # only select added, copied, modified or renamed files
    log_cmd << " --diff-filter=ACMR --name-only #{refspec}"
    log = `#{log_cmd}`.split("\n")
    
    unless diffmode
      sha, msg = log.shift.split(' ', 2)
    end
    
    # ignore tests, specs and submodules
    files = log.reject { |file| file =~ /^(test|spec|features)\// or File.directory?(file) }
    if files.empty?
      $stderr.puts "Nothing to deploy"
      exit(1)
    end
    
    cmd = %(cap deploy:upload FILES='#{files.join(",")}')
    
    if options['stage']
      cmd << %( RAILS_ENV=#{options[stage]} )
    end
    
    if options['environment']
      cmd << %( -S branch=#{options['environment']})
    end
    if files.any? { |file| file =~ /^public\/(stylesheets|javascripts)\// }
      # uses a custom capistrano task
      cmd << ' deploy:clear_cached_assets'
    end
    unless options['no-restart']
      cmd << ' deploy:restart'
    end
    
    if msg and sha
      puts %(Deploying commit [#{sha}]: #{msg})
    else
      puts %(Deploying #{files.size} file#{files.size == 1 ? '' : 's'})
    end
    system cmd
  end
end
