class User {
  constructor(data) {
    this.uid = data.uid;
    this.fullName = data.fullName;
    this.email = data.email;
    this.phoneNumber = data.phoneNumber;
    this.role = data.role;
    this.address = data.address || {};
    this.createdAt = data.createdAt;
    this.updatedAt = data.updatedAt;
  }

  static collectionRef() {
    const { db } = require('../config/firebase');
    return db.collection('users');
  }

  static async findById(uid) {
    const doc = await this.collectionRef().doc(uid).get();
    if (!doc.exists) return null;
    return new User({ uid: doc.id, ...doc.data() });
  }

  static async findByEmail(email) {
    const snapshot = await this.collectionRef().where('email', '==', email).limit(1).get();
    if (snapshot.empty) return null;
    const doc = snapshot.docs[0];
    return new User({ uid: doc.id, ...doc.data() });
  }

  static async create(data) {
    const { admin } = require('../config/firebase');
    const ref = this.collectionRef().doc(data.uid);
    
    const userData = {
      ...data,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await ref.set(userData);
    return new User({ uid: ref.id, ...userData });
  }

  async update(data) {
    const { admin } = require('../config/firebase');
    const updateData = {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await User.collectionRef().doc(this.uid).update(updateData);
    Object.assign(this, data);
    return this;
  }
}

module.exports = User;