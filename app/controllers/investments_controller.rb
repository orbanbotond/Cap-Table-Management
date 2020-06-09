class InvestmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_for_investments, only: [:index, :create]
  before_action :set_investment, only: [:show, :edit, :update, :destroy]

  # GET /investments
  # GET /investments.json
  def index2
    @investments = Investment.all.order_by( created_at: :asc)
    @investments_prev_round = @investments[0..-2]
    @last_investment = @investments.last
    @total_shares = @investments.map{|investment| investment.shares}.sum
    @total_shares_in_prev_round = @investments_prev_round.map{|investment| investment.shares}.sum
    @post_money_valuation = @last_investment.investment.to_f * @total_shares / @last_investment.shares
    @pre_money_valuation = @post_money_valuation - @last_investment.investment

    # I am going to calculate based on the pre money valuation
    @current_price_per_share = @post_money_valuation.to_f / @total_shares
  end


  def index
    calculate_display_data
  end

  # GET /investments/1
  # GET /investments/1.json
  def show
  end

  # GET /investments/new
  def new
    @investment = Investment.new
  end

  # GET /investments/1/edit
  def edit
  end

  # POST /investments
  # POST /investments.json
  def create
    @investment = Investment.new(investment_params)

    respond_to do |format|
      if @investment.save
        format.html { redirect_to @investment, notice: 'Investment was successfully created.' }
        format.json { render :show, status: :created, location: @investment }
      else
        format.html { render :new }
        format.json { render json: @investment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /investments/1
  # PATCH/PUT /investments/1.json
  def update
    respond_to do |format|
      if @investment.update(investment_params)
        format.html { redirect_to @investment, notice: 'Investment was successfully updated.' }
        format.json { render :show, status: :ok, location: @investment }
      else
        format.html { render :edit }
        format.json { render json: @investment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /investments/1
  # DELETE /investments/1.json
  def destroy
    @investment.destroy
    respond_to do |format|
      format.html { redirect_to investments_url, notice: 'Investment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_investment
      @investment = Investment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def investment_params
      params.require(:investment).permit(:investment, :shares, :name)
    end

    def set_user_for_investments
      Mongoid::Multitenancy.current_tenant = current_user
    end

    def calculate_display_data
      @investments = Investment.all.order_by( created_at: :asc)
      @total_shares = @investments.map{|investment| investment.shares}.sum
      @row_data = @investments.reduce({investments: [], }) do |accumulator, investment|
        row_data = { name: investment.name }
        prev_total_shares = accumulator.fetch(:total_shares, 0)
        total_shares = prev_total_shares + investment.shares
        post_money_valuation = investment.investment.to_f * total_shares / investment.shares
        pre_money_valuation = post_money_valuation - investment.investment

        row_data[:post_finance] = {}
        row_data[:post_finance][:investment] = investment.investment
        row_data[:post_finance][:nr_shares] = investment.shares
        row_data[:post_finance][:price_per_share] = post_money_valuation / total_shares
        row_data[:post_finance][:stake] = investment.shares.to_f / @total_shares
        row_data[:post_finance][:valuation] = post_money_valuation

        unless investment == @investments.last
          row_data[:pre_finance] = {}
          row_data[:pre_finance][:investment] = investment.investment
          row_data[:pre_finance][:stake] = investment.shares.to_f / total_shares
          row_data[:pre_finance][:valuation] = pre_money_valuation
        end

        {
            investments: accumulator[:investments] << row_data,
            total_shares: total_shares,
            pre_money_valuation: pre_money_valuation,
            post_money_valuation: post_money_valuation
        }
      end

      @displaydata = @row_data[:investments]
      @post_money_valuation = @row_data[:post_money_valuation]
      @pre_money_valuation = @row_data[:pre_money_valuation]
    end
end
