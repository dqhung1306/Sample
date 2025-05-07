class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class LinkedList:
    def __init__(self):
        self.head = None
        self.tail = None

    def append(self, data):
        new_node = Node(data)
        if self.head is None:
            self.head = new_node
            self.tail = new_node  # Cập nhật tail khi danh sách rỗng
            return
        else:
            self.tail.next = new_node
            self.tail = new_node

    def insert_at_index(self, data, position):
        if position < 0:
            return
        new_node = Node(data)
        if position == 0:
            new_node.next = self.head
            self.head = new_node
            if self.tail is None:  # Trường hợp thêm vào danh sách rỗng
                self.tail = new_node
            return
        current = self.head
        for _ in range(position - 1):
            if current is None:
                return
            current = current.next
        if current is None:
            return
        new_node.next = current.next
        current.next = new_node
        if new_node.next is None:  # Nếu thêm vào cuối thì cập nhật tail
            self.tail = new_node

    def deleteX(self, X):
        current = self.head
        previous = None
        while current and current.data != X:
            previous = current
            current = current.next
        if current is None:
            return
        if previous is None:
            self.head = current.next
        else:
            previous.next = current.next
        if current == self.tail:
            self.tail = previous

    def show(self):
        current = self.head
        while current:
            print(current.data, end=' -> ')
            current = current.next
        print('None')

    def search(self, data):
        if self.head is None:
            return False
        current = self.head
        while current and current.data != data:
            current = current.next
        return current is not None

head = LinkedList()
head.append(1)
head.append(2)
head.append(3)
head.append(4)
head.append(5)
head.insert_at_index(6,2)
head.show()