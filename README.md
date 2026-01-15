# Self-Hosted SSH Gateway

This project allows you to use your own VPS as a secure gateway to access your Kaggle Notebooks via SSH using **SSH Key Authentication**.

## 🚀 Features
- **High Speed**: Direct connection via your own VPS.
- **Secure**: Uses SSH Keys (No passwords needed on VPS).
- **Reliable**: Reconnects automatically (keep-alive).

## 🛠️ Setup Instructions

### Step 1: Prepare your VPS (Gateway)
1. SSH into your VPS as `root`.
2. Copy `vps/setup_gateway.sh` to your VPS and run it:
   ```bash
   bash setup_gateway.sh
   ```
3. **IMPORTANT**: The script will ask to generate a keypair. Say **Yes (y)**.
4. **Copy the Private Key** displayed at the end of the script! You need this for Kaggle.

### Step 2: Connect from Kaggle (Node)
1. Open your Kaggle Notebook.
2. Enable **Internet Access** in settings.
3. Open `NOTEBOOK_EXAMPLE.ipynb`.
4. Enter your **VPS IP** and paste the **Private Key** (from Step 1) into the variables.
5. Run the cells. The last cell will keep running to maintain the tunnel.

### Step 3: Connect from Windows (Client)
1. Navigate to the `windows` folder on your PC.
2. Run `setup_config.bat` to configure your SSH host `kaggle`.
3. Open a terminal and run:
   ```bash
   ssh kaggle
   ```
   *Note: You might need to add your personal SSH key to the VPS `tunnel` user's `authorized_keys` if you want passwordless access from Windows too, otherwise you will be prompted for the 'tunnel' user password (if one was set) or it might fail if PasswordAuth is disabled.*

## 📁 Project Structure
- `vps/`: Scripts for the Gateway server (Generates SSH Keys).
- `kaggle/`: Scripts for the Kaggle environment (Uses SSH Keys).
- `windows/`: Configuration scripts for the Client.

## 📄 License
MIT
