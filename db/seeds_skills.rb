skills_data = {
  'Backend & Databases' => ['Ruby on Rails', 'Node.js', 'Python', 'Django', 'FastAPI', 'Java', 'Spring Boot', 'Go (Golang)', 'C# / .NET', 'PHP', 'Laravel', 'PostgreSQL', 'MySQL', 'MongoDB', 'Redis', 'GraphQL', 'REST API', 'Elasticsearch', 'SQLite', 'Firebase', 'Supabase', 'Prisma', 'Cassandra', 'Neo4j'],
  'Frontend & Web' => ['React', 'Next.js', 'Vue.js', 'Nuxt.js', 'TypeScript', 'JavaScript', 'HTML5 & CSS3', 'Tailwind CSS', 'Sass / SCSS', 'Svelte', 'Redux', 'Zustand', 'Webpack', 'Vite', 'Bootstrap', 'WebAssembly', 'UI/UX Design', 'Figma'],
  'AI, Data & ML' => ['Data Science', 'Machine Learning', 'Deep Learning', 'PyTorch', 'TensorFlow', 'Computer Vision', 'Natural Language Processing (NLP)', 'Pandas', 'NumPy', 'Scikit-Learn', 'OpenCV', 'LLMs & RAG', 'Data Engineering', 'Apache Spark', 'Business Intelligence', 'Data Visualization', 'PowerBI', 'Tableau'],
  'DevOps & Cloud' => ['Docker', 'Kubernetes', 'AWS', 'Google Cloud (GCP)', 'Microsoft Azure', 'CI/CD Pipelines', 'GitHub Actions', 'Terraform', 'Linux / Bash', 'Nginx', 'Microservices', 'System Design', 'Serverless'],
  'Mobile Development' => ['Flutter', 'React Native', 'iOS / Swift', 'Android / Kotlin', 'Dart', 'Expo', 'PWA'],
  'Cybersecurity' => ['Cybersecurity', 'Penetration Testing', 'Network Security', 'Ethical Hacking', 'OWASP Top 10', 'Cryptography', 'Security Audit'],
  'Software Engineering' => ['Git & GitHub', 'Agile / Scrum', 'Test Driven Development (TDD)', 'Jest', 'RSpec', 'C++', 'C Language', 'Rust', 'Problem Solving', 'Technical Writing', 'Team Leadership']
}

count = 0
skills_data.each do |cat, list|
  list.each do |sname|
    skill = Skill.find_or_initialize_by(name: sname)
    skill.category = cat
    skill.save!
    count += 1
  end
end

puts "Successfully seeded #{count} skills across #{skills_data.keys.count} categories!"
