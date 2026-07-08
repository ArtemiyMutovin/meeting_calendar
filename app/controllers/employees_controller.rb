class EmployeesController < ApplicationController
  def index
    @employees = Employee.alphabetical
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)

    if @employee.save
      redirect_to employees_path, notice: "Сотрудник добавлен."
    else
      @employees = Employee.alphabetical
      flash.now[:alert] = @employee.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    redirect_to employees_path, notice: "Сотрудник удалён."
  end

  private

  def employee_params
    params.require(:employee).permit(:name, :email)
  end
end
