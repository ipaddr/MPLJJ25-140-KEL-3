/**
 * AI Service for nutrition status classification
 */

/**
 * Classify nutrition status based on weight, height, age and gender
 * @param {Object} data - The nutrition data
 * @returns {Object} Nutrition classification and recommendations
 */
const classifyNutritionStatus = async (data) => {
  const { weight, height, age, gender } = data;
  
  // Calculate BMI
  const heightInMeters = height / 100;
  const bmi = weight / (heightInMeters * heightInMeters);
  
  // Determine status based on WHO standards
  // This is a simplified example - in a real application, 
  // you would use more comprehensive age/gender specific charts
  let status = '';
  let recommendations = [];
  
  if (bmi < 18.5) {
    status = 'KURANG';
    recommendations = [
      'Tingkatkan asupan kalori sehat',
      'Konsumsi protein berkualitas tinggi',
      'Makan lebih sering dengan porsi kecil'
    ];
  } else if (bmi >= 18.5 && bmi < 25) {
    status = 'NORMAL';
    recommendations = [
      'Pertahankan pola makan seimbang',
      'Konsumsi beragam jenis makanan',
      'Rutin berolahraga'
    ];
  } else {
    status = 'BERLEBIH';
    recommendations = [
      'Batasi makanan tinggi gula dan lemak',
      'Tingkatkan konsumsi sayur dan buah',
      'Tingkatkan aktivitas fisik'
    ];
  }
  
  // In a real application, you would connect to an ML model API here
  
  return {
    bmi: bmi.toFixed(2),
    status,
    recommendations
  };
};

module.exports = {
  classifyNutritionStatus
};