enum SendMode {
  single, // Mode for one-to-one file transfer where a single file is sent directly to one recipient
  multiple, // Mode for one-to-many file transfer where the file is sent to multiple recipients
  link, // Mode for one-to-many file transfer where the recipient initiates the download using a shared link
}
