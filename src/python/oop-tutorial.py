#!/usr/bin/env python3

# -----------------------------------------------------------------------------
# GenomeScan internship repository.
# Copyright (C) 2023 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Contact information: info@jboom.org.
# -----------------------------------------------------------------------------

# Imports:
import math
from pympler import asizeof


class ClassName:
    # Class body
    pass

    """
    The first naming convention that you need to know about is related to the 
    fact that Python doesnt distinguish between private, protected, and public
    attributes like Java and other languages do. In Python, all attributes are
    accessible in one way or another. However, Python has a well-established
    naming convention that you should use to communicate that an attribute or
    method isnt intended for use from outside its containing class or object.
    
    The naming convention consists of adding a leading underscore to the
    members name.

    Public: radius, calculate_area()
    Non-public: _radius, _calculate_area()
    """


class Circle:
    def __init__(self, radius):
        self.radius = radius

    def calculate_area(self):
        return round(math.pi * self.radius**2, 2)


def test_circle():
    circle_1 = Circle(42)
    circle_2 = Circle(7)
    print(circle_1.radius)
    print(circle_1.calculate_area())
    print(circle_2.radius)
    print(circle_2.calculate_area())
    circle_1.radius = 100
    print(circle_1.radius)
    print(circle_1.calculate_area())


# test_circle()


class ObjectCounter:
    num_instances = 0

    def __init__(self):
        # ObjectCounter.num_instances += 1
        """
        In the above example, you’ve used the class name to access
        .num_instances inside .__init__(). However, using the built-in type()
        function is best because it’ll make your class more flexible:
        """
        type(self).num_instances += 1
        """
        The built-in type() function returns the class or type of self, which
        is ObjectCounter in this example. This subtle change makes your class
        more robust and reliable by avoiding hard-coding the class that
        provides the attribute.
        """


def test_object_counter():
    print(ObjectCounter.num_instances)
    counter = ObjectCounter()
    print(counter.num_instances)


# test_object_counter()


class Car:
    def __init__(self, make, model, year, color):
        self.make = make
        self.model = model
        self.year = year
        self.color = color
        self.started = False
        self.speed = 0
        self.max_speed = 200
        """
        You explicitly initialize the attributes .started, .speed,
        and .max_speed with sensible values that don’t come from the user.
        """


def test_car():
    toyota_camry = Car("Toyota", "Camry", 2022, "Red")
    print(toyota_camry.make)
    print(toyota_camry.model)
    print(toyota_camry.color)
    print(toyota_camry.speed)


# test_car()


class SampleClass:
    class_attr = 100

    def __init__(self, instance_attr):
        self.instance_attr = instance_attr

    def method(self):
        print(f"Class attribute: {self.class_attr}")
        print(f"Instance attribute: {self.instance_attr}")


def test_sample_class():
    print(SampleClass.class_attr)
    print(SampleClass.__dict__)
    print(SampleClass.__dict__["class_attr"])
    print("---------------------------")

    instance = SampleClass("Hello!")
    print(instance.instance_attr)
    print(instance.method())
    print(instance.__dict__)
    print(instance.__dict__["instance_attr"])

    instance.__dict__["instance_attr"] = "Hello, Pythonista!"
    print(instance.instance_attr)


# test_sample_class()


class Record:
    """Hold a record of data."""


def test_record():
    john = {
        "name": "John Doe",
        "position": "Python Developer",
        "department": "Engineering",
        "salary": 80000,
        "hire_date": "2020-01-01",
        "is_manager": False,
    }
    john_record = Record()
    for field, value in john.items():
        setattr(john_record, field, value)
    print(john_record.name)
    print(john_record.department)
    print(john_record.__dict__)


# test_record()


class User:
    pass


def test_user():
    """
    You can also use dot notation and an assignment to add new attributes and
    methods to a class dynamically.
    """
    # Add instance attributes dynamically
    jane = User()
    jane.name = "Jane Doe"
    jane.job = "Data Engineer"
    print(jane.__dict__)

    # Add methods dynamically
    def __init__(self, name, job):
        self.name = name
        self.job = job

    User.__init__ = __init__
    print(User.__dict__)

    linda = User("Linda Smith", "Team Lead")
    print(linda.__dict__)


# test_user()


class Circle:
    """
    How would you do that without changing your class interface? The quickest
    approach to this problem is to use a property and implement the validation
    logic in the setter method.
    """

    def __init__(self, radius):
        self.radius = radius

    @property
    def radius(self):
        return self._radius

    @radius.setter
    def radius(self, value):
        if not isinstance(value, int | float) or value <= 0:
            raise ValueError("positive number expected")
        self._radius = value

    def calculate_area(self):
        return round(math.pi * self._radius**2, 2)


def test_new_circle():
    circle_1 = Circle(100)
    print(circle_1.radius)

    circle_1.radius = 500
    circle_1.radius = 0
    circle_2 = Circle(-100)
    circle_3 = Circle("300")


# test_new_circle()

class Square:
    def __init__(self, side):
        self.side = side

    @property
    def side(self):
        return self._side

    @side.setter
    def side(self, value):
        if not isinstance(value, int | float) or value <= 0:
            raise ValueError("positive number expected")
        self._side = value

    def calculate_area(self):
        return round(self._side**2, 2)


class PositiveNumber:
    """
    The first thing to notice in this example is
    that you moved all the classes to a shapes.py file. In that file, you
    define a descriptor class called PositiveNumber by implementing
    the .__get__() and .__set__() special methods, which are part of the
    descriptor protocol.

    Next, you remove the .radius property from Circle and the .side property
    from Square. In Circle, you add a .radius class attribute, which holds an
    instance of PositiveNumber. You do something similar in Square, but the
    class attribute is appropriately named .side.
    """
    def __set_name__(self, owner, name):
        self._name = name

    def __get__(self, instance, owner):
        return instance.__dict__[self._name]

    def __set__(self, instance, value):
        if not isinstance(value, int | float) or value <= 0:
            raise ValueError("positive number expected")
        instance.__dict__[self._name] = value


class Circle:
    radius = PositiveNumber()

    def __init__(self, radius):
        self.radius = radius

    def calculate_area(self):
        return round(math.pi * self.radius**2, 2)


class Square:
    side = PositiveNumber()

    def __init__(self, side):
        self.side = side

    def calculate_area(self):
        return round(self.side**2, 2)


def test_positive_number():
    circle = Circle(100)
    print(circle.radius)
    circle.radius = 500
    print(circle.radius)
    circle.radius = 0

    square = Square(200)
    print(square.side)
    square.side = 300
    print(square.side)
    square.side = -100


#test_positive_number()

class Point:
    __slots__ = ("x", "y")
    def __init__(self, x, y):
        self.x = x
        self.y = y

def test_point():
    point = Point(4, 8)
    point.__dict__

# Additional information:
# =======================
# https://realpython.com/python-classes/
