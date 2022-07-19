
# 分布式 ID 生成器 uuid

  * 简单介绍

        使用 JDK 自带的 UUID 生成，去除 - 字符，剩余 32 位，无中心化，基本不会出现重复

  * 存在问题

        UUID 长达 32 位，存储占用空间比较大

        UUID 总体来看是无序的，使用 mysql B+TREE 索引会有性能问题 (所有叶子节点形成链表，无序插入需要进行父节点分裂)

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-boot

  * 实现比较简单：

        /**
         * ID 生成器
         *
         * @author hlm
         * @param <R>
         */
        public interface IdGenerator<R> {

            /**
             * 生成 ID
             *
             * @return
             */
            public R generate();

        }

        /**
         * UUID 生成器
         *
         * @author hlm
         */
        @Component
        public class UuidLength32Generator implements IdGenerator<String> {

            @Override
            public String generate() {
                char[] chars = new char[32];
                String uuid = UUID.randomUUID().toString();
                for(int i=0, off = 0; i<uuid.length(); i++) {
                    char ch = uuid.charAt(i);
                    if(ch != '-') {
                        chars[off++] = ch;
                    }
                }
                return new String(chars);
            }

        }

        /**
         * 测试接口
         *
         * @author hlm
         */
        @RestController
        public class TestController {

            @Autowired
            private IdGenerator<String> idGenerator;

            @RequestMapping(path="welcome")
            public String welcome() {
                return idGenerator.generate();
            }

        }
