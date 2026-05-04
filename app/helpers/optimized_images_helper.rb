module OptimizedImagesHelper
  def optimized_course_image_tag(course, alt:, class_name:, width:, height:, sizes: "(max-width: 600px) 400px, (max-width: 900px) 800px, 1200px")
    return unless course&.course_image&.attached?

    small = course.course_image.variant(:webp_small).processed
    medium = course.course_image.variant(:webp_medium).processed
    large = course.course_image.variant(:webp_large).processed

    image_tag(
      medium,
      alt: alt,
      class: class_name,
      width: width,
      height: height,
      loading: "lazy",
      decoding: "async",
      srcset: "#{url_for(small)} 400w, #{url_for(medium)} 800w, #{url_for(large)} 1200w",
      sizes: sizes
    )
  end

  def optimized_course_thumb_tag(course, alt:, class_name:, width:, height:)
    return unless course&.course_image&.attached?

    image_tag(
      course.course_image.variant(:webp_thumb).processed,
      alt: alt,
      class: class_name,
      width: width,
      height: height,
      loading: "lazy",
      decoding: "async"
    )
  end

  def optimized_static_image_tag(image, alt:, class_name:, width:, height:)

    file_path = Rails.root.join("app/assets/images/#{image}")
    return unless File.exist?(file_path)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(file_path),
      filename: File.basename(file_path),
      content_type: determine_content_type(file_path)
    )

    if File.extname(file_path).downcase == '.svg'
      image_url = image
    else
      image_url = blob.variant(format: :webp, saver: { quality: 80 }).processed
    end

    image_tag(
      image_url,
      alt: alt,
      class: class_name,
      width: width,
      height: height,
      loading: "lazy",
      decoding: "async"
    )
  end

  private

  def determine_content_type(image_path)
    extension = File.extname(image_path).downcase.delete('.')
    
    content_types = {
      'jpg' => 'image/jpeg',
      'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'svg' => 'image/svg+xml',
      'webp' => 'image/webp',
    }
    
    content_types[extension] || 'image/jpeg'
  end
end
