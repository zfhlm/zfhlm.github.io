
# 分布式事务 seata 代码结构

  * 简单说明

        当引入 seata 之后，代码中本地事务、分布式事务混合在一起，不便于管理，需要对两者进行分离管理

### 分离管理

  * 分布式系统中，各个子服务应该统一使用某个模式的分布式事务：

        从 XA 、AT、 TCC 模式中选择一个，额外可以多使用一个 saga 模式

        并发量大的情况下，建议只使用 TCC 模式，一般的业务对表改动的幅度要求并不大

        第三方系统对接，可以只使用 TCC (通过中间服务适配第三方 API，也能达到 saga 的回滚效果)，或者使用 TCC + saga 模式

  * 假设有以下接口：

        public interface IUserService {

            public void methodA();

            public void methodB();

            public void methodC();

        }

  * 实现类，有本地事务、分布式事务：

        @Service
        public class UserService implements IUserService {

            @GlobalTransactional
            @Transactional
            @Override
            public void methodA() {

            }

            @Transactional
            @Override
            public void methodB() {

            }

            @Transactional
            @Override
            public void methodC() {

            }

        }

  * 可以抽离 分布式事务 到单独的一个实现类中，例如：


        @Service
        public class GlobalUserMethodA {

            @GlobalTransactional
            public void methodA() {

            }

        }

        @Service
        public class UserService implements IUserService {

            @Autowired
            private GlobalUserMethodA globalUserMethodA;

            @Transactional
            @Override
            public void methodA() {
                globalUserMethodA.methodA();
            }

            @Transactional
            @Override
            public void methodB() {

            }

            @Transactional
            @Override
            public void methodC() {

            }

        }

  * 以上，可以将 GlobalTransactional 事务类都存放到同一个 package 中，由其是使用了 TCC 或 saga，更能看出分离的优劣
