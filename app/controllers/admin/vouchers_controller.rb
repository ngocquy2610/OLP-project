class Admin::VouchersController < Admin::BaseController
  before_action :set_voucher, only: [ :edit, :update, :destroy ]

  def index
    @vouchers = Voucher.order(created_at: :desc)
  end

  def new
    @voucher = Voucher.new
  end

  def edit; end #action edit. render form edit.

  def create
    @voucher = Voucher.new(voucher_params)
    @voucher.active_price = calculate_active_price(@voucher.discount_percent)

    if @voucher.save
      respond_to do |format| #respond_to block to handle different response formats (HTML, Turbo Stream)
        format.turbo_stream do # If the request is a Turbo Stream request, we want to update a part instead of full page reload
          @vouchers = Voucher.order(created_at: :desc)
          flash.now[:notice] = I18n.t("messages.admin.vouchers.created")
          # flash[:key]: save at session. --> appear when render or redirect
          # flash.now[:key]: save at current request, only for turbo stream, not for html. --> appear immediately
          render turbo_stream: [ #render the turbo_stream response (format.turbo_stream)
            turbo_stream.replace("profile_content", template: "admin/vouchers/index"), #replace all container
            turbo_stream.update("flash_messages", partial: "layouts/flash") #update flash message container (inner html)
          ]
        end
        format.html { redirect_to admin_vouchers_path, notice: I18n.t("messages.admin.vouchers.created") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @voucher.errors.full_messages.join(", ")
          render turbo_stream: [
            turbo_stream.replace("profile_content", template: "admin/vouchers/new"),
            turbo_stream.update("flash_messages", partial: "layouts/flash")
          ], status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    @voucher.assign_attributes(voucher_params) #method of Rails --> assign attribute but not save.
    @voucher.active_price = calculate_active_price(@voucher.discount_percent) #take the discount percent to calculate active price

    if @voucher.save
      respond_to do |format|
        format.turbo_stream do
          @vouchers = Voucher.order(created_at: :desc)
          flash.now[:notice] = I18n.t("messages.admin.vouchers.updated")
          render turbo_stream: [
            turbo_stream.replace("profile_content", template: "admin/vouchers/index"),
            turbo_stream.update("flash_messages", partial: "layouts/flash")
          ]
        end
        format.html { redirect_to admin_vouchers_path, notice: I18n.t("messages.admin.vouchers.updated") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @voucher.errors.full_messages.join(", ")
          render turbo_stream: [
            turbo_stream.replace("profile_content", template: "admin/vouchers/edit"),
            turbo_stream.update("flash_messages", partial: "layouts/flash")
          ], status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @voucher.destroy

    respond_to do |format|
      format.turbo_stream do
        @vouchers = Voucher.order(created_at: :desc)
        flash.now[:notice] = I18n.t("messages.admin.vouchers.deleted")
        render turbo_stream: [
          turbo_stream.replace("profile_content", template: "admin/vouchers/index"),
          turbo_stream.update("flash_messages", partial: "layouts/flash")
        ]
      end
      format.html { redirect_to admin_vouchers_path, notice: I18n.t("messages.admin.vouchers.deleted") }
    end
  end

  private

  def calculate_active_price(discount_percent)
    return nil if discount_percent.blank? || discount_percent.to_i <= 0

    20000 / discount_percent.to_f * 100
    # minimum price is 20k so this mathematic calculate the active price base on the minimum price
  end

  def set_voucher
    @voucher = Voucher.find_by(id: params[:id])
  end

  def voucher_params
    params.require(:voucher).permit(:code, :discount_percent, :expires_at, :usage_limit, :active)
  end
end
