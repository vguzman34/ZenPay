const bcrypt = require('bcryptjs');
const v2Hash = '$2a$10$lTdAPwuyFU4nUkRSk0W6ge2WLHk0KQxc0T9mj1vzfiUXofZKyMnDe';
console.log('V2 hash matches Admin123:', bcrypt.compareSync('Admin123', v2Hash));
console.log('V2 hash matches admin123:', bcrypt.compareSync('admin123', v2Hash));
