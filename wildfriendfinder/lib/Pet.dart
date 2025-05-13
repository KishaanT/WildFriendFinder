class Pet {
  String? name;
  String? age;
  String? species;
  String? breed;
  String? sex;
  String? description;
  String? ownerId;
  String? imageAssetsPath;

  Pet({
    this.name,
    this.age,
    this.species,
    this.breed,
    this.sex,
    this.description,
    this.ownerId,
    this.imageAssetsPath
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
      'imageAssetsPath': imageAssetsPath,
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
      imageAssetsPath: data['imageAssetsPath']
    );
  }
}