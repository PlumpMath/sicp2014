# [First Class Function]


* SICP���� �����ϴ� first class procedure�� 4���� ���

  - ������ ���� �� �� �ִ�. �ٽ� ����, �̸��� ���� �� �ִ�.
  - ���ν����� ���ڷ� �� �� �ִ�.
  - ���ν����� ����� ����� �� �� �ִ�.
  - ������ ���� �ӿ� ���� ���� �� �ִ�.


* Wikipedia���� �����ϴ� First Class Function(http://en.m.wikipedia.org/wiki/First-class_function)

  - �Ӹ��ۿ��� SICP�� �� 4���� ���� �ο�
  - ��̴� �͸��Լ� �������� ��ҷ� ���ٰ� �Ѵ�.


## Java������ �ϱ��Լ�

* Java 8 ������ ���

```java
public class HigherOrderFuncSimulate {
 
   public static void main(String[] args) {
       higherOrderSimulateMethod(new FirstClassFuncSimulate() {
           public void call() {
               speakFrankly().call();
           }
       });
   }
 
   public static void higherOrderSimulateMethod(FirstClassFuncSimulate obj) {       
       obj.call();
   }
 
   public static FirstClassFuncSimulate speakFrankly() {
       System.out.println("I'm not real Higher!");

       return new FirstClassFuncSimulate() {
           public void call() {
        	   show();
           };
       };
   }
 
   public static void show(){
	   System.out.println("And nowhere first-class Method in Java world!");
   }
   
}
 
interface FirstClassFuncSimulate {
   public void call();
}
```

* Java 8 ������ ��� java.util.function�� lambda�� ����
  
  - Fucntion<InputType, ResultType>, BiFunction<Type1, Type2, Result> �� �Լ� �䳻�� ���� interface ����
  - ���ٽ��� syntatic sugar�� ������ ���� �ڹٹ������� �ڵ� ����
  - ������ ���ÿ����÷ο�( http://stackoverflow.com/questions/15198979/lambda-expressions-and-higher-order-functions) ����

  - ���� �������� �� �� �ִ� �͵�
  - 1. Function Ÿ���� ������ Function Ÿ�� �Լ��� ���ڷ� ���� �� �ִ�.
  - 2. Collection ���꿡�� stream �Ǵ� parallelStream ȣ�� ���� �޼��忡 Function Ÿ�� ���� Ȥ�� ���ٽ��� ���ڷ� ���� �� �ִ�.
  - 3. Function Ÿ�� �Լ����� ���ٽ��� ������ �� �ִ�.
  - 4. �׷��� �ڷᱸ���� �Լ� ����ִ� ����? �Ʒ� �ڵ� �ּ� ����

```java
public class HigherOrder {		
	
   public static void main(String[] args) {
      HashMap<String, Function<String, String>> funcMaps = initFunctionMaps();  // ���� �߰�
      Function<Integer, Long> addOne = add(1L);

      System.out.println(addOne.apply(1)); 

      Arrays.asList("test", "new")
	.parallelStream()  
	.map(funcMaps.get("stringFunc1"))  // ���� ����  
	.forEach(System.out::println);
   }

   private static Function<Integer, Long> add(long l) {
      return (Integer i) -> l + i;
   }

   private static Function<String, String> camelize = 
	(str) -> str.substring(0, 1).toUpperCase() + str.substring(1);

   // �ڷᱸ���� �Լ� ����ֱ� (���� �߰�)			
   public static HashMap<String, Function<String, String>> initFunctionMaps(){
      HashMap<String, Function<String, String>> functionMaps
	   = new HashMap<String, Function<String, String>>();
		
      functionMaps.put("stringFunc1", (str) -> str.substring(0, 1).toUpperCase() + str.substring(1) );
      functionMaps.put("stringFunc2", (str) -> str + " , hello? you see stringFunc2.");
		
      return functionMaps;		
   }
}
```


  
