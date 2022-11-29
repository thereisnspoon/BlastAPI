# Shiden RPC Node Setup 

```
screen
mkdir -p ~/setup && cd ~/setup
wget https://raw.githubusercontent.com/ImStaked/BlastAPI/main/Houston%20-%20Testnet/node_setup/Shiden/Shiden_Node_Setup.sh
chmod +x Shiden_Node_Setup.sh
./Shiden_Node_Setup.sh &
screen -d
```

#### Estimated Wait Time = 2 Hours
- The script will create a file upon completion but only when it has finished. 

- To check if the script is done use this command. It will return FINISHED!!! when complete
```
cat ~/setup/done.txt
```

- It is now safe to remove the setup files 
```
rm -rf ~/setup
```

- Useful commands.

```journalctl -f -u shiden```   <--- Follow the node logs

```systemctl status shiden```   <--- Status of the service

```journalctl -b -u shiden```   <--- All shiden service logs since last boot



