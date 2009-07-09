# TODO setup ssh keys for assembla

namespace :slicehost do

  desc "Set up slice"
  task :setup do
    set :user, "root"
    set :port, "22"
    change_root_password()
    create_admin()
    add_admin_as_sudo()
  end

  desc "Change root password"
  task :change_root_password do
    set(:new_root_password) { Capistrano::CLI.password_prompt("New Root password: ") }
    set(:confirmed_new_root_password) { Capistrano::CLI.password_prompt("RETYPE New Root password: ") }

    if (new_root_password == confirmed_new_root_password)

      run "passwd root" do |channel, stream, data|
        case data
          when "(current) UNIX password: " then channel.send_data("#{password}\n")
          when "Enter new UNIX password: " then channel.send_data("#{new_root_password}\n")
          when "Retype new UNIX password: " then channel.send_data("#{confirmed_new_root_password}\n")
          else "Password change failed"
        end  
      end
      
    else
      puts "Passwords do not match"
    end
    
  end
  
  desc "Create admin user"
  task :create_admin do
    set(:new_admin_password) { Capistrano::CLI.password_prompt("New Admin password: ") }
    set(:confirmed_new_admin_password) { Capistrano::CLI.password_prompt("RETYPE New Admin password: ") }
    
    if (new_root_password == confirmed_new_root_password)
      run "sudo adduser admin --quiet --disabled-password --gecos ''"

      run "passwd admin" do |channel, stream, data|
        case data
          when "Enter new UNIX password: " then channel.send_data("#{new_admin_password}\n")
          when "Retype new UNIX password: " then channel.send_data("#{confirmed_new_admin_password}\n")
          else "Setting admin password failed #{data}"
        end  
      end

    else
      puts "Password do not match"
    end
  end

  desc "Add admin to sudoers"
  task :add_admin_as_sudo do
    run "echo 'admin ALL=(ALL) ALL' >> /etc/sudoers"
  end

end