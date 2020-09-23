#!usr/bin/env/ruby
require 'fraction'
class Matrix
  attr_accessor :rows

  # Creates a new Matrix with a (list of lists)
  def initialize (row_list)
    @rows = row_list
    @rows_reduced = 0
  end

  # Calculates the minimum element in a row
  def min (row_num)
    row = @rows[row_num]
    min = row[0]
    row.each do |num|
      if min == 0 then
        min = num
      end
      if (num < min) && (num != 0) then
        min = num
      end
    end
    return min
  end

  # Calculates the common factor of a row
  def has_common (row_num, row_min)
    row = @rows[row_num]
    result = false
    if row_min != 0 then
      result = true
      row.each do |num|
        if result == true then
          if (num != 0) && ((num.abs).modulo(row_min.abs) != 0) then
            result = false
          end
        end
      end
    end
    return result
  end

  # Divides a whole row by its common factor (Row #, Common Factor)
  def reduce (row_num, row_min)
    row = @rows[row_num]
    for i in 0..(row.length - 1) do
      @rows[row_num][i] = (@rows[row_num][i])/row_min
      if @rows[row_num][i] == -0.0 then
        @rows[row_num][i] = 0.0
      end
    end
    num, den = row_min.to_fraction
    if den == 1 then
      puts "R#{row_num + 1} -> R#{row_num + 1}/#{num}"
    else
      puts "R#{row_num + 1} -> R#{row_num + 1}/(#{num}/#{den})"
    end
  end

  # Swaps two rows with each other (Index #'s)
  def swap (row1, row2)
    row1_copy = @rows[row1]
    row2_copy = @rows[row2]

    new_row1 = row2_copy
    new_row2 = row1_copy

    @rows[row1] = new_row1
    @rows[row2] = new_row2
    puts "R#{row1 + 1} <-> R#{row2 + 1}"
  end

  # Calculates the value needed to multiply a row through, with a pivot value
  # row value for a particular column
  def cancel_val (pivot_val, cancel)
    return cancel/pivot_val
  end

  # Substitutes Pivot Row (Array Index) with the row you are performing a row
  # operation on (Array Index). Applies cancel_val (See cancel_val above) as
  # the multiplier
  def substitute (pivot_row_num, cancel_row_num, cancel_val)
    for i in 0..(((@rows[pivot_row_num]).length) - 1)
      @rows[cancel_row_num][i] = @rows[cancel_row_num][i] - (cancel_val)*(@rows[pivot_row_num][i])
      if @rows[cancel_row_num][i] == -0.0 then
        @rows[cancel_row_num][i] = 0.0
      end
    end
    num, den = cancel_val.to_fraction
    outp = ""
    if den == 1 then
      outp += "#{num}"
    else
      outp += "#{num}/#{den}"
    end
    if (cancel_val < 0) then
      puts "R#{cancel_row_num + 1} -> R#{cancel_row_num + 1} - (#{outp})R#{pivot_row_num + 1}"
    else
      puts "R#{cancel_row_num + 1} -> R#{cancel_row_num + 1} - (#{outp})R#{pivot_row_num + 1}"
    end
  end

  # Prints matrix to Standard Output
  def print_matrix
    width = @rows.flatten.max.to_s.size
    if width > 4 then
      width = width - 0.5
    end
    puts @rows.map { |a|
      "|#{ a.map { |i|
      outp = ""
      num, den = i.to_fraction
      if den == 1 then
        outp += "#{num}"
      else
        outp += "#{num}/#{den}"
      end
      "#{outp.rjust(width)} |"
      }.join }"
    }
    puts "↓"
  end

  def find_better_pivot (row_num, column_num, last_row)
    curr_row = row_num
    curr_col = column_num
    while (curr_row <= last_row) do
      curr_row_val = @rows[curr_row][curr_col]
      if (curr_row_val != 0.0) && (curr_row_val != -0.0) then
        return curr_row
      end
      curr_row = curr_row + 1
    end
    return row_num
  end
end

def rref (matrix)
  puts "Original ⌗"
  matrix.print_matrix

  pivot_columns = Array.new()
  pivot_rows = Array.new()
  rows = matrix.rows #(Updates in synch with prints/reductions)

  # Zero Out (Below Pivot)
  current_pivot = 0
  piv_col_num = 0
  row_amount = rows.length
  col_amount = rows[0].length
  piv_max = if row_amount > col_amount then col_amount else row_amount end
  while (current_pivot < piv_max) && (piv_col_num < piv_max) do
    last_row = rows.length - 1 # (nth row #)
    pivot_row = current_pivot
    curr_row = pivot_row + 1 # (Current Row #)
    pivot = true
    while curr_row <= last_row && pivot == true do
      pivot_val = rows[pivot_row][piv_col_num] # (Pivot value)
      if (pivot_val != 0.0) && (pivot_val != -0.0) && (pivot_val != nil) then
        if (pivot_columns.include?(piv_col_num) == false) then
          pivot_rows.push(pivot_row)
          pivot_columns.push(piv_col_num)
        end
        curr_val = rows[curr_row][piv_col_num]
        cancel = matrix.cancel_val(pivot_val, curr_val)
        if (cancel != 0.0) && (cancel != -0.0) && (cancel != nil) then
          matrix.substitute(pivot_row, curr_row, cancel)
          row_min = matrix.min(curr_row)
          if (matrix.has_common(curr_row, row_min)) == true then
            matrix.reduce(curr_row, row_min)
          end
          matrix.print_matrix
          rows = matrix.rows
        end
        curr_row = curr_row + 1
      else
        if (pivot_val != nil) then
          better_pivot_row = matrix.find_better_pivot(pivot_row, piv_col_num, last_row)
          if better_pivot_row != pivot_row then
            matrix.swap(better_pivot_row, pivot_row)
            rows = matrix.rows
            matrix.print_matrix
          else
            pivot = false
          end
        end
      end
    end
    piv_col_num = piv_col_num + 1
    current_pivot = current_pivot + 1
  end

  # Adds last pivot to pivot row/column lists
  last_pivot_row = current_pivot - 1
  last_pivot_col = piv_col_num - 1
  if (rows[last_pivot_row][last_pivot_col] != 0 && rows[last_pivot_row][last_pivot_col] != nil) then
    pivot_rows.push(last_pivot_row)
    pivot_columns.push(last_pivot_col)
  end

  # Simplifies first pivot to 1 (Required for REF (why))
  rows = matrix.rows
  piv1row = pivot_rows[0]
  piv1col = pivot_columns[0]
  piv1val = rows[piv1row][piv1col]
  if((rows[0][0] != 1) && (rows[0][0] != 1.0)) then
    matrix.reduce(piv1row, piv1val)
  end
  puts ""
  puts "Row Echelon Form"

  # Zero Out (Above Pivot) - Starting at bottom right pivot
  piv_row_last = pivot_rows.length - 1
  piv_row = pivot_rows[piv_row_last]
  column_amount = pivot_columns.length - 1
  column_counter = column_amount
  while piv_row >= 0 do
    piv_col = pivot_columns[column_counter]
    curr_row = piv_row - 1
    while curr_row >= 0 do
      pivot_val = rows[piv_row][piv_col]
      if (pivot_val != 0.0) && (pivot_val != -0.0) && (pivot_val != nil) && (pivot_val != 0) then
        curr_val = rows[curr_row][piv_col]
        cancel = matrix.cancel_val(pivot_val, curr_val)
        if ((cancel != 0.0) && (cancel != -0.0) && (cancel != nil) && (cancel != 0)) then
          matrix.substitute(piv_row, curr_row, cancel)
          row_min = matrix.min(curr_row)
          if matrix.has_common(curr_row, row_min) == true then
            matrix.reduce(curr_row, row_min)
          end
          matrix.print_matrix
          rows = matrix.rows
        end
      end
      curr_row = curr_row - 1
    end
    piv_row = piv_row - 1
    column_counter = column_counter - 1
  end

  # Reduces pivots to 1
  for i in 0..(pivot_rows.length - 1)
    prow = pivot_rows[i]
    pcol = pivot_columns[i]
    pivot_val = (matrix.rows)[prow][pcol]
    if (pivot_val != 0) && (pivot_val != nil) then
      matrix.reduce(prow, pivot_val)
    end
  end

  puts "Reduced Row Echelon Form"
  matrix.print_matrix
end

# Driver
row_list = Array.new()
done = false
quit = false
puts "1. Enter each row of your matrix with a space between entries
2. Type \"Start\" or \"s\" in a new line when done, \"Cancel\" or \"c\" to quit)"

# Takes input and builds matrix
while (done == false && quit == false) do
  input = gets.chomp
  if (input == "Start" || input == "start" || input == "s") then
    done = true
  else
    if (input == "Cancel" || input == "cancel" || input == "c") then
      quit = true
    else
      row = input.split(" ")
      row_nums = Array.new()
      row.each do |string|
        row_nums.push(string.to_f)
      end
      row_list.push(row_nums)
    end
  end
end

# Starts program
if quit == true then
  puts "Program Exited"
else
  row1 = row_list[0]
  row1length = row1.length
  row_list.each do |row|
    if row.length != row1length then
      puts "Invalid Matrix Input"
    end
  end
  matrix = Matrix.new(row_list)
  rref(matrix)
end
