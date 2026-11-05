module FormHelper
  def label_class
    "
      block
      text-sm
      font-medium
      text-gray-700
      dark:text-gray-300
      mb-2
    "
  end

  def input_class
    " 
      block
      w-full
      px-3
      py-1
      rounded-xl
      border-gray-300
      shadow-sm
      focus:border-blue-500
      focus:ring-blue-500
      dark:bg-gray-700
      dark:border-gray-600
      dark:text-white
    "
  end

  def textarea_class
    " 
      block
      w-full
      rounded-xl
      border-gray-300
      shadow-sm
      focus:border-blue-500
      focus:ring-blue-500
      dark:bg-gray-700
      dark:border-gray-600
      dark:text-white
      px-3
      py-1
    "
  end

  def file_input_class
    " 
      block
      w-full
      text-sm
      text-gray-500
      file:mr-4
      file:rounded-lg
      file:border-0
      file:bg-blue-50
      file:px-4
      file:py-2
      file:text-sm
      file:font-semibold
      file:text-blue-700
      hover:file:bg-blue-100
      px-3
      py-1
    "
  end
end