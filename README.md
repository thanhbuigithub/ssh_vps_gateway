# Self-Hosted SSH Gateway

This project allows you to use your own VPS as a secure gateway to access your Kaggle Notebooks (or any other constrained environment) via SSH, bypassing firewalls and NATs using robust Reverse SSH Tunneling.

## 🚀 Features
- **High Speed**: Direct connection via your own VPS.
- **Secure**: Uses SSH encryption and dedicated user isolation.
- **Reliable**: Reconnects automatically (keep-alive).
- **Control**: You own the infrastructure.

## 📋 Architecture
```
[Kaggle VM] --(Reverse Tunnel :2222)--> [VPS Gateway] <--(ProxyJump)--- [Windows Client]
(Runs SSHd)                              (Loopback)
```

## 🛠️ Setup Instructions

### Step 1: Prepare your VPS (Gateway)
*Run this once on your VPS.*
1. SSH into your VPS as `root`.
2. Copy the content of `vps/setup_gateway.sh` to your VPS.
3. Run it:
   ```bash
   bash setup_gateway.sh
   ```
4. Follow the prompts to set a password for the dedicated `tunnel` user.

### Step 2: Connect from Kaggle (Node)
1. Open your Kaggle Notebook.
2. Enable **Internet Access** in settings.
3. clone this repository or upload the files.
4. Open `NOTEBOOK_EXAMPLE.ipynb`.
5. Enter your VPS IP and the 'tunnel' password in the config cell.
6. Run the cells. The last cell will keep running - this maintains the tunnel.

### Step 3: Connect from Windows (Client)
*Run this once to configure your local SSH client.*
1. Navigate to the `windows` folder on your PC.
2. Double-click `setup_config.bat`.
3. Enter your VPS IP address when prompted.
   - This adds a `Host kaggle` entry to your `~/.ssh/config`.

### Step 4: Login!
Open any terminal (PowerShell, CMD, or VSCode Terminal) and run:
```bash
ssh kaggle
```
**Authentication Flow:**
1. **Jump Host**: You will be asked for the `tunnel` user's password (from Step 1).
2. **Kaggle Host**: You will be asked for the `root` user's password.
   - Default: `kaggle` (configured in `kaggle/connect_vps.sh`).

## 📁 Project Structure
- `vps/`: Scripts for the Gateway server.
- `kaggle/`: Scripts for the Kaggle environment (installs SSH Server & Tunnel).
- `windows/`: Configuration scripts for the Client.

## 🔧 Troubleshooting
- **Connection Refused**: Ensure the Kaggle notebook cell is still running.
- **Permission Denied**: Check if you typed the correct passwords (tunnel vs root).
- **Timeout**: VPS might have blocked ports? (Unlikely as we tunnel over standard SSH port 22).

## 📄 License
MIT
