class Child {
  constructor(data) {
    this.id = data.id;
    this.parentId = data.parentId;
    this.fullName = data.fullName;
    this.dateOfBirth = data.dateOfBirth;
    this.gender = data.gender;
    this.createdAt = data.createdAt;
    this.updatedAt = data.updatedAt;
  }

  static collectionRef() {
    const { db } = require('../config/firebase');
    return db.collection('children');
  }

  static async findById(id) {
    const doc = await this.collectionRef().doc(id).get();
    if (!doc.exists) return null;
    return new Child({ id: doc.id, ...doc.data() });
  }

  static async findByParentId(parentId) {
    const snapshot = await this.collectionRef().where('parentId', '==', parentId).get();
    return snapshot.docs.map(doc => new Child({ id: doc.id, ...doc.data() }));
  }

  static async create(data) {
    const { admin } = require('../config/firebase');
    const ref = this.collectionRef().doc();
    
    const childData = {
      id: ref.id,
      ...data,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await ref.set(childData);
    return new Child(childData);
  }

  async update(data) {
    const { admin } = require('../config/firebase');
    const updateData = {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await Child.collectionRef().doc(this.id).update(updateData);
    Object.assign(this, data);
    return this;
  }

  async delete() {
    await Child.collectionRef().doc(this.id).delete();
    return true;
  }
}

module.exports = Child;