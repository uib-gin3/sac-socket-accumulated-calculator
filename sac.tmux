# sac.tmux — SAC socket calculator tmux layout.
#
# Excute with
#
#   tmux start-server \; source-file ./sac.tmux
#
# Exit with:
#
#   Ctrl-b : kill-server
#
# Layout:
#   +-----------------+---------------------+
#   |                 | ./sac-bench         |
#   |  ./sac-server   +---------------------+
#   |                 | nc localhost 1234   |
#   +-----------------+---------------------+
#
#
# Recreate the session if it already exists, waiting until the old
# sac-server has released port 1234 before starting a new one.
# run-shell is synchronous, so the queue stops here until it finishes.
run-shell "if tmux has-session -t =sac 2>/dev/null; then tmux kill-session -t =sac && sleep 0.5; fi"

new-session -d -s sac -n sac "./sac-server --debug; echo 'type tmux kill-server to exit'; exec bash"
split-window -h -t sac:0.0 -c "#{pane_current_path}" "printf \"I'm about to execute the benchmark during 30 seconds with the command ./sac-bench -c 5 -r 10 -d 30.\\nDo you want to proceed [Y/n]? \"; read ans || ans=n; case \"\$ans\" in [Yy]|\"\") sleep 0.5; ./sac-bench -c 5 -r 10 -d 30;; esac; echo 'type tmux kill-server to exit'; exec bash"
split-window -v -t sac:0.1 -c "#{pane_current_path}" "sleep 0.5; nc localhost 1234; exec bash"
select-pane -t sac:0.1

# From outside tmux this attaches in the current terminal;
# from inside tmux it switches the current client to the session.
attach-session -t sac
