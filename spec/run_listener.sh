if [ ! -p vim-commands ]; then
  mkfifo vim-commands
fi

while true; do
  sh -c "clear && $(cat vim-commands)"
done
