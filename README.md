# SnitchClyde 🕵️‍♂️  
_Discord Email Enumeration Exploit_

SnitchClyde is a lightweight bash-based exploit that leverages a subtle information disclosure vulnerability in Discord's `/api/v9/users/@me` endpoint. By injecting a forged `email_token`, it triggers different server responses depending on whether the supplied email is already registered on Discord. This allows attackers to enumerate valid Discord-registered email addresses with high accuracy.

---

## ⚙️ Features

- Detects if an email is already registered on Discord  
- Works with a single email or a list of emails  
- Supports output to CSV  
- Optional verbose output  
- Fully bash-based, no dependencies

---

## 📦 Usage

```bash
./snitchclyde.sh --token AUTH_TOKEN [options]
```

---

## 🔧 Options

| Option      | Description                                                           |
| ----------- | --------------------------------------------------------------------- |
| `--token`   | *(Required)* Your Discord session token                               |
| `--email`   | Check a single email address                                          |
| `--list`    | Path to a file with emails/passwords in `email:password` format       |
| `--dir`     | Directory containing multiple files to parse for matching emails      |
| `--domain`  | Used with `--dir`, only emails matching this domain will be extracted |
| `--output`  | Save results to a CSV file                                            |
| `--verbose` | Show unregistered emails in output                                    |
| `--threads` | Number of concurrent threads for list checking (default: 1)           |

---

> ⚠️ **Disclaimer**  
> This tool is intended for **educational and security research purposes only**.  
> Unauthorized use **may violate Discord's Terms of Service** and **local laws**.  
> The author assumes **no liability** for misuse or damages caused by this software.

