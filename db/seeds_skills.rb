skills_data = {
  'Backend & Databases' => [
    'Ruby on Rails', 'Node.js', 'Python', 'Django', 'FastAPI', 'Java', 'Spring Boot',
    'Go (Golang)', 'C# / .NET', 'PHP', 'Laravel', 'Express.js', 'NestJS', 'PostgreSQL',
    'MySQL', 'MongoDB', 'Redis', 'GraphQL', 'REST API', 'Elasticsearch', 'SQLite',
    'Firebase', 'Supabase', 'Prisma', 'Cassandra', 'Neo4j', 'DynamoDB', 'CockroachDB',
    'Apache Kafka', 'RabbitMQ', 'gRPC', 'WebSockets', 'Elixir', 'Phoenix'
  ],
  'Frontend & Web' => [
    'React', 'Next.js', 'Vue.js', 'Nuxt.js', 'TypeScript', 'JavaScript', 'HTML5 & CSS3',
    'Tailwind CSS', 'Sass / SCSS', 'Svelte', 'SvelteKit', 'Redux', 'Zustand', 'Webpack',
    'Vite', 'Bootstrap', 'WebAssembly', 'UI/UX Design', 'Figma', 'Storybook',
    'Shadcn UI', 'Radix UI', 'Three.js', 'WebGL', 'Alpine.js', 'Angular'
  ],
  'AI, Data & ML' => [
    'Data Science', 'Machine Learning', 'Deep Learning', 'PyTorch', 'TensorFlow',
    'Computer Vision', 'Natural Language Processing (NLP)', 'Pandas', 'NumPy',
    'Scikit-Learn', 'OpenCV', 'LLMs & RAG', 'LangChain', 'LlamaIndex', 'Hugging Face',
    'Data Engineering', 'Apache Spark', 'Apache Airflow', 'Business Intelligence',
    'Data Visualization', 'PowerBI', 'Tableau', 'dbt', 'BigQuery', 'Snowflake',
    'Vector Databases (Pinecone/Milvus)'
  ],
  'DevOps & Cloud' => [
    'Docker', 'Kubernetes', 'AWS', 'Google Cloud (GCP)', 'Microsoft Azure',
    'CI/CD Pipelines', 'GitHub Actions', 'Terraform', 'Ansible', 'Linux / Bash',
    'Nginx', 'Microservices', 'System Design', 'Serverless', 'Helm', 'Prometheus',
    'Grafana', 'Datadog', 'Cloudflare', 'Vercel / Render'
  ],
  'Mobile & Cross-Platform' => [
    'Flutter', 'React Native', 'iOS / Swift', 'Android / Kotlin', 'Dart', 'Expo',
    'PWA', 'Jetpack Compose', 'SwiftUI', 'Ionic', 'Capacitor'
  ],
  'Cybersecurity' => [
    'Cybersecurity', 'Penetration Testing', 'Network Security', 'Ethical Hacking',
    'OWASP Top 10', 'Cryptography', 'Security Audit', 'Burp Suite', 'Wireshark',
    'SOC Analysis', 'Incident Response', 'IAM & OAuth2'
  ],
  'Software Engineering & Methods' => [
    'Git & GitHub', 'Agile / Scrum', 'Test Driven Development (TDD)', 'Jest',
    'RSpec', 'Playwright', 'Cypress', 'C++', 'C Language', 'Rust', 'Problem Solving',
    'Technical Writing', 'Team Leadership', 'Code Review', 'CI/CD Best Practices'
  ]
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
