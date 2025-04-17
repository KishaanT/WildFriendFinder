class Pet {
  String? name;
  String? age;
  String? species;
  String? breed;
  String? sex;
  String? description;
  int? ownerId; // Your custom userId, not Firebase UID

  Pet({
    this.name,
    this.age,
    this.species,
    this.breed,
    this.sex,
    this.description,
    this.ownerId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'species': species,
      'breed': breed,
      'sex': sex,
      'description': description,
      'ownerId': ownerId,
    };
  }

  factory Pet.fromFirestore(Map<String, dynamic> data) {
    return Pet(
      name: data['name'],
      age: data['age'],
      species: data['species'],
      breed: data['breed'],
      sex: data['sex'],
      description: data['description'],
      ownerId: data['ownerId'],
    );
  }
}