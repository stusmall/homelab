This is a set up for my home server.  Feel free to look around for ideas, but this probably isn't useful for anyone but me

To run:
* Clone the repo anywhere on the target machine
* Run bootstrap.sh
* Generate a key goto https://panel.dreamhost.com/?tree=home.api and for permissions select `dns-*`
* After rebuilding and switching into the new config, it will prompt for the dreamhost API key
* Join tailscale to the tailnet with `tailscale up --auth-key=$KEY`
