const bcrypt = require('bcryptjs');
const conversationHash = '$2b$10$TyADFHRlFFU6NT9q3313v.2K5uqHqKjJxgYs4s4dKyItLXFjnydJm';
console.log('Conversation hash matches Admin123:', bcrypt.compareSync('Admin123', conversationHash));
console.log('Conversation hash matches admin123:', bcrypt.compareSync('admin123', conversationHash));
