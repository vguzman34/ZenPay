const bcrypt = require('bcryptjs');
const salt = bcrypt.genSaltSync(10);
const hash = bcrypt.hashSync('Admin123', salt);
console.log('Hash for Admin123:', hash);
console.log('Verify:', bcrypt.compareSync('Admin123', hash));
