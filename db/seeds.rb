# Seeds for development/demo purposes. Safe to run multiple times (idempotent).
puts "Seeding demo data..."

ActiveRecord::Base.transaction do

	# sample tags to assign to seeded courses
	@sample_tags = %w[ruby rails javascript stimulus web beginner advanced testing deployment]

	# Users
	teacher = User.find_or_initialize_by(email: "teacher@example.com")
	teacher.password = "password"
	teacher.password_confirmation = "password"
	teacher.role = :teacher
	teacher.confirmed_at ||= Time.current
	teacher.save!

	student = User.find_or_initialize_by(email: "student@example.com")
	student.password = "password"
	student.password_confirmation = "password"
	student.role = :student
	student.confirmed_at ||= Time.current
	student.save!

	# Admin user (idempotent) with known password
	admin_email = "admin@gmail.com"
	admin = User.find_or_initialize_by(email: admin_email)
	if admin.new_record?
		admin.password = "123456"
		admin.password_confirmation = "123456"
		admin.role = :admin
		admin.confirmed_at ||= Time.current
		admin.save!
		puts "Created admin user: #{admin_email} (password: 123456)"
	else
		puts "Admin user already exists: #{admin_email}"
	end

	# Helper to attach file only if present and not already attached
	attach_file_unless_attached = lambda do |record, attachment_name, filepath, content_type: nil|
		full_path = Rails.root.join(filepath)
		return unless File.exist?(full_path)
		att = record.send(attachment_name)
		return if att.attached?
		att.attach(io: File.open(full_path), filename: File.basename(full_path), content_type: content_type)
	end

	# Attach a random course image from app/assets/images/courses if available
	attach_random_course_image = lambda do |course_record|
		att = course_record.course_image
		return if att.attached?
		images_dir = Rails.root.join("app", "assets", "images", "courses")
		return unless Dir.exist?(images_dir)
		files = Dir.children(images_dir).select { |f| File.file?(images_dir.join(f)) }
		return if files.empty?
		choice = files.sample
		full_path = images_dir.join(choice)
		content_type = Marcel::MimeType.for(Pathname.new(full_path)) rescue nil
		course_record.course_image.attach(io: File.open(full_path), filename: choice, content_type: content_type)
	end

	########################################
	# Course 1: Ruby Basics
	########################################
	course1 = Course.find_or_initialize_by(name: "Ruby Basics")
	course1.user = teacher
	course1.description = "An introductory course to Ruby programming language."
	course1.price = 0
	course1.tag = "ruby"
	course1.status = :published
	# Attach a random course image from assets/images/courses before saving (validation requires image)
	attach_random_course_image.call(course1)
	course1.save!

	topic1 = course1.topics.find_or_create_by!(name: "Getting Started with Ruby")

	lesson1 = topic1.lessons.find_or_create_by!(name: "Introduction to Ruby")
	lesson1.description = "Overview of Ruby, installing, IRB and basic syntax."
	lesson1.save!
	attach_file_unless_attached.call(lesson1, :video, "app/assets/video/Learn_octal_in_113_seconds_720P.mp4", content_type: "video/mp4")

	# Practices for lesson
	lesson1.practices.find_or_create_by!(question: "Which symbol starts a symbol literal in Ruby?", type: :multiple_choice) do |p|
		p.answers = ["@", ":", "$", "%"].join(",")
		p.correct_answers = [":" ].join(",")
	end

	lesson1.practices.find_or_create_by!(question: "True or False: Ruby is statically typed.", type: :true_false) do |p|
		p.answers = ["true", "false"].join(",")
		p.correct_answers = ["false"].join(",")
	end

	# Topic-level exams (multiple questions)
	topic1.exams.find_or_create_by!(question: "What does IRB stand for?", type: :multiple_choice) do |e|
		e.answers = ["Interactive Ruby", "Internal Ruby Bridge", "Immediate Ruby Band", "Interface Ruby"].join(",")
		e.correct_answers = ["Interactive Ruby"].join(",")
	end

	########################################
	# Course 2: Rails Essentials
	########################################
	course2 = Course.find_or_initialize_by(name: "Rails Essentials")
	course2.user = teacher
	course2.description = "Learn the fundamentals of Ruby on Rails by building a small app."
	course2.price = 20000
	course2.tag = "rails"
	course2.status = :published
	attach_random_course_image.call(course2)
	course2.save!

	topic2 = course2.topics.find_or_create_by!(name: "MVC and Routing")

	lesson2 = topic2.lessons.find_or_create_by!(name: "Controllers and Views")
	lesson2.description = "Understand controllers, views, and the request cycle."
	lesson2.save!
	attach_file_unless_attached.call(lesson2, :video, "app/assets/video/Learn_octal_in_113_seconds_720P.mp4", content_type: "video/mp4")

	lesson2.practices.find_or_create_by!(question: "Which method renders a view from a controller?", type: :multiple_choice) do |p|
		p.answers = ["render", "redirect_to", "send_file", "respond_to"].join(",")
		p.correct_answers = ["render"].join(",")
	end

	topic2.exams.find_or_create_by!(question: "True or False: `redirect_to` ends the request by issuing an HTTP redirect.", type: :true_false) do |e|
		e.answers = ["true", "false"].join(",")
		e.correct_answers = ["true"].join(",")
	end

	########################################
	# Small dataset: additional sample course
	########################################
	course3 = Course.find_or_initialize_by(name: "JavaScript for Rails Developers")
	course3.user = teacher
	course3.description = "Add interactivity to Rails apps using modern JavaScript."
	course3.price = 0
	course3.tag = "javascript"
	course3.status = :published
	attach_random_course_image.call(course3)
	course3.save!

	topic3 = course3.topics.find_or_create_by!(name: "Stimulus & Turbo")
	lesson3 = topic3.lessons.find_or_create_by!(name: "Intro to Stimulus Controllers")
	lesson3.description = "Create lightweight controllers to enhance UX."
	lesson3.save!
	attach_file_unless_attached.call(lesson3, :video, "app/assets/video/Learn_octal_in_113_seconds_720P.mp4", content_type: "video/mp4")

	lesson3.practices.find_or_create_by!(question: "Stimulus controllers are placed inside which folder by convention?", type: :multiple_choice) do |p|
		p.answers = ["app/javascript/controllers", "app/controllers", "app/assets/javascripts", "app/views"].join(",")
		p.correct_answers = ["app/javascript/controllers"].join(",")
	end

	puts "Seeding finished: Created users, courses, topics, lessons, exams, and practices."
end

	# Create 100 additional sample courses (idempotent)
	puts "Creating 100 additional seeded courses..."
	# Re-create helper lambdas here so they're available in this scope
	attach_file_unless_attached = lambda do |record, attachment_name, filepath, content_type: nil|
		full_path = Rails.root.join(filepath)
		next unless File.exist?(full_path)
		att = record.send(attachment_name)
		next if att.attached?
		att.attach(io: File.open(full_path), filename: File.basename(full_path), content_type: content_type)
	end

	attach_random_course_image = lambda do |course_record|
		att = course_record.course_image
		return if att.attached?
		images_dir = Rails.root.join("app", "assets", "images", "courses")
		return unless Dir.exist?(images_dir)
		files = Dir.children(images_dir).select { |f| File.file?(images_dir.join(f)) }
		return if files.empty?
		choice = files.sample
		full_path = images_dir.join(choice)
		content_type = Marcel::MimeType.for(Pathname.new(full_path)) rescue nil
		course_record.course_image.attach(io: File.open(full_path), filename: choice, content_type: content_type)
	end

	# Use the teacher user created above (or find existing)
	teacher = User.find_by!(email: "teacher@example.com")

	ActiveRecord::Base.transaction do
		(1..100).each do |i|
		name = "Seeded Course #{i}"
		course = Course.find_or_initialize_by(name: name)
		course.user = teacher
		course.description = "Autogenerated sample course ##{i}"
		# Randomly make some free and some paid courses (0 or >= 20000)
		course.price = [0, 20000, 30000, 50000].sample
		# assign a random tag from @sample_tags if not set
		course.tag = @sample_tags.sample
		course.status = :published
		# Attach random image before saving to satisfy validations
		attach_random_course_image.call(course)
		course.save!

		topic = course.topics.find_or_create_by!(name: "Topic for #{name}")

		lesson = topic.lessons.find_or_create_by!(name: "Lesson 1 for #{name}")
		lesson.description = "Auto-generated lesson for #{name}"
		# Attach video if available
		attach_file_unless_attached.call(lesson, :video, "app/assets/video/Learn_octal_in_113_seconds_720P.mp4", content_type: "video/mp4")
		lesson.save!

		# One practice and one exam per course
		lesson.practices.find_or_create_by!(question: "Sample question for #{name}", type: :multiple_choice) do |p|
			p.answers = ["Option A", "Option B", "Option C", "Option D"].join(",")
			p.correct_answers = ["Option A"].join(",")
		end

		topic.exams.find_or_create_by!(question: "Sample exam question for #{name}", type: :true_false) do |e|
			e.answers = ["true", "false"].join(",")
			e.correct_answers = ["true"].join(",")
		end
	end

	end

	puts "Created 100 seeded courses."

	# Create 100 more seeded courses (101..200)
	puts "Creating 100 additional seeded courses (101..200)..."
	ActiveRecord::Base.transaction do
		(101..200).each do |i|
			name = "Seeded Course #{i}"
			course = Course.find_or_initialize_by(name: name)
			course.user = teacher
			course.description = "Autogenerated sample course ##{i}"
			course.price = [0, 20000, 30000, 50000].sample
			course.tag = @sample_tags.sample
			course.status = :published
			attach_random_course_image.call(course)
			course.save!

			topic = course.topics.find_or_create_by!(name: "Topic for #{name}")

			lesson = topic.lessons.find_or_create_by!(name: "Lesson 1 for #{name}")
			lesson.description = "Auto-generated lesson for #{name}"
			attach_file_unless_attached.call(lesson, :video, "app/assets/video/Learn_octal_in_113_seconds_720P.mp4", content_type: "video/mp4")
			lesson.save!

			lesson.practices.find_or_create_by!(question: "Sample question for #{name}", type: :multiple_choice) do |p|
				p.answers = ["Option A", "Option B", "Option C", "Option D"].join(",")
				p.correct_answers = ["Option A"].join(",")
			end

			topic.exams.find_or_create_by!(question: "Sample exam question for #{name}", type: :true_false) do |e|
				e.answers = ["true", "false"].join(",")
				e.correct_answers = ["true"].join(",")
			end
		end
	end

	puts "Created additional 100 seeded courses (101..200)."

	puts "Done. Run `bin/rails db:seed` (or `rails db:seed`) to load this data." 
