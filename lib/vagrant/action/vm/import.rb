module Vagrant
  class Action
    module VM
      class Import
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env.ui.info "Importing base VM (#{env.env.box.ovf_file})"

          # Import the virtual machine
          env.env.vm.vm = VirtualBox::VM.import(env.env.box.ovf_file) do |progress|
            env.ui.report_progress(progress.percent, 100, false)
          end

          # Flag as erroneous and return if import failed
          return env.error!(:virtualbox_import_failure) if !env['vm'].vm

          # Import completed successfully. Continue the chain
          @app.call(env)
        end

        def recover(env)
          # Interrupted, destroy the VM
          env["actions"].run(:destroy)
        end
      end
    end
  end
end
