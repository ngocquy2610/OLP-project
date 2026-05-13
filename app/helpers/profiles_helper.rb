module ProfilesHelper
  def mask_key(value)
    return t("profiles.not_updated") if value.blank?
    "•" * value.to_s.length
  end
end
