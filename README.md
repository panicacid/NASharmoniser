# NASharmoniser

Ey up shaggas! Let me introduce you t' NASharmoniser project. This script came to life out of sheer necessity to tackle them pesky file and directory name inconsistencies on a customer's QNAP NAS. 

You see, they ran a mix of MacOS and Windows devices and the MacOS device users decided to use some NTFS Reserved Characters in their file and folder names (numpties!) so the Windows devices weren't seeing eye to eye on certain characters, causing a right muddle. 

So, NASharmoniser was born from neccessity to fix this absolute mess of a file system, ready to sanitize file and folder names across t' network drive, making sure they play nice no matter which system you're on. To run this we SSH'd onto the NAS and executed the script. If the NAS doesn't have GIT just create the script manually in your favourite text editor (or whatever the NAS gives you, in this instance I had to use VI *cires in nano user*).

## Features

- **Character Wrangler**: It’s on a mission, seeking out and swapping unsupported characters in file and directory names.
- **Chatty Companion**: Hits a snag? No bother, it'll natter with you to decide how to carry on.
- **Log Aficionado**: Keeps a neat and tidy log of all its doings, so you can track changes without breaking a sweat.
- **Unique Name Keeper**: It’s vigilant, ensuring every renaming operation keeps things unique to avoid any data mix-ups.


## Usage

1. Clone this repository to your local machine or NAS:
   ```
   git clone https://github.com/PanicAcid/NASharmoniser.git
   cd NASharmoniser
   ```

2. Ensure the script is executable:
   ```
   chmod +x nasharmoniser.sh
   ```

3. Run the script, providing the directory path as an argument:
   ```
   ./nasharmoniser.sh /path/to/directory
   ```

### Example

Suppose you have a directory containing files with unsupported characters like `File*:Name.txt` or ` Doc.doc`. Running NASharmoniser on this directory will rename these files to `File_Name.txt` and `_Doc.doc`, respectively, resolving any cross-platform naming conflicts. This will also fix directories with invalid characters and spaces at the beginning and end (How does that even happen?! - Who knows.. But lets fix it!)

```
./nasharmoniser.sh /path/to/directory
```

## Log Files

Each run of the NASharmoniser script creates a log file named `rename_operation_<date_time>.log` in the same directory from where the script is run. This log file contains a record of all renaming operations and any error messages.

## Contributing

Feel free to fork this project, open issues, or submit pull requests. Any feedback is highly appreciated!
