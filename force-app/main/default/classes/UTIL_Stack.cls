/*
    This class contains various Apex Stack Implementations
*/
public class UTIL_Stack
{
	public static final Integer MAX_STACK_DEPTH = 1000;

	public class NullValueNotAllowedException extends Exception
	{
	}
	public class StackOverflowException extends Exception
	{
	}
	public class StackUnderflowException extends Exception
	{
	}

	//ObjectStack - This stack stores a list of Apex Objects
	public class ObjectStack
	{
		private List<Object> stack;

		public ObjectStack()
		{
			stack = new List<Object>();
		}

		public void push(Object obj)
		{
			if(obj == null)
				throw new NullValueNotAllowedException();

			if(this.isFull())
				throw new StackOverflowException();

			stack.add(obj);
		}

		public Object pop()
		{
			if(isEmpty())
				throw new StackUnderflowException();

			return stack.remove(lastItemIndex);
		}

		public Object peak()
		{
			return peek(lastItemIndex);
		}

		public Object peek(Integer index)
		{
			if(isEmpty() || index < 0)
				throw new StackUnderflowException();
			else if(index >= size())
				throw new StackOverflowException();

			return stack.get(index);
		}

		public Boolean isEmpty()
		{
			return stack.isEmpty();
		}
		public Boolean isFull()
		{
			return MAX_STACK_DEPTH == size();
		}
		public Integer size()
		{
			return stack.size();
		}

		private Integer lastItemIndex
		{
			get
			{
				return size() - 1;
			}
		}
	}
}