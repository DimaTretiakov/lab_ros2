#!/usr/bin/env python3
import time
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist

class Forward10s(Node):
    def __init__(self):
        super().__init__('forward_10s')

        self.declare_parameter('cmd_vel_topic', '/cmd_vel')
        self.declare_parameter('speed', 0.4)     # м/с (очень медленно)
        self.declare_parameter('duration', 10.0)  # сек

        self.topic = self.get_parameter('cmd_vel_topic').value
        self.speed = float(self.get_parameter('speed').value)
        self.duration = float(self.get_parameter('duration').value)

        self.pub = self.create_publisher(Twist, self.topic, 10)
        self.start = time.time()
        self.timer = self.create_timer(0.1, self.tick)  # 10 Hz

        self.get_logger().info(f"Forward {self.duration}s to {self.topic} at {self.speed} m/s")

    def stop(self):
        msg = Twist()
        msg.linear.x = 0.0
        msg.angular.z = 0.0
        self.pub.publish(msg)

    def tick(self):
        t = time.time() - self.start
        if t < self.duration:
            msg = Twist()
            msg.linear.x = self.speed
            msg.angular.z = 0.0
            self.pub.publish(msg)
        else:
            self.stop()
            self.get_logger().info("Done. Stop and exit.")
            rclpy.shutdown()

def main():
    rclpy.init()
    node = Forward10s()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    try:
        node.stop()
    except Exception:
        pass
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
