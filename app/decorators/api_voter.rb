class ApiVoter
  include ExtendedPoroBehaviour

  attr_accessor :name,
                :email,
                :faculty_code,
                :department_code,
                :ssn,
                :phone,
                :student_number

  def attributes
    {
      'name': @name,
      'email': @email,
      'faculty_code': @faculty_code,
      'department_code': @department_code,
      'ssn': @ssn,
      'phone': @phone,
      'student_number': @student_number
    }
  end
end
