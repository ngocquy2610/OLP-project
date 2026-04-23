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
end
