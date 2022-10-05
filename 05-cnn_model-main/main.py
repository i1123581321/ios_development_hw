import matplotlib.pyplot as plt
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
import coremltools as ct

classes = ('plane', 'car', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse',
           'ship', 'truck')

class_labels = [
    'air plane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse',
    'ship', 'truck'
]

MODEL_PATH = ".\\cifar_net.pth"


class MyNet(nn.Module):
    def __init__(self):
        super(MyNet, self).__init__()
        # input
        # batch size 4
        # 3 * 32 * 32
        self.conv1 = nn.Conv2d(3, 6, 5)
        # 6 * 28 * 28
        self.pool = nn.MaxPool2d(2, 2)
        # 6 * 14 * 14
        self.conv2 = nn.Conv2d(6, 16, 5)
        # 16 * 10 * 10
        # pool 2, 2
        # 16 * 5 * 5
        self.fc1 = nn.Linear(16 * 5 * 5, 120)
        # 120
        self.fc2 = nn.Linear(120, 84)
        # 84
        self.fc3 = nn.Linear(84, 10)

    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        x = x.view(-1, 16 * 5 * 5)
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        x = self.fc3(x)
        return x


def show(img: torch.Tensor):
    img = img * 0.25 + 0.5
    npimg = img.numpy()
    plt.imshow(np.transpose(npimg, (1, 2, 0)))
    plt.show()


def load_data_set(
) -> (torch.utils.data.DataLoader, torch.utils.data.DataLoader):
    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.25, 0.25, 0.25))
    ])

    trainset = torchvision.datasets.CIFAR10(root=".\\data",
                                            train=True,
                                            download=False,
                                            transform=transform)
    trainloader = torch.utils.data.DataLoader(trainset,
                                              batch_size=4,
                                              shuffle=True,
                                              num_workers=2)

    testset = torchvision.datasets.CIFAR10(root=".\\data",
                                           train=False,
                                           download=False,
                                           transform=transform)

    testloader = torch.utils.data.DataLoader(testset,
                                             batch_size=4,
                                             shuffle=True,
                                             num_workers=2)

    return trainloader, testloader


def train_model():
    trainloader, testloader = load_data_set()
    net = MyNet()
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.SGD(net.parameters(), lr=0.001, momentum=0.9)

    # train
    for epoch in range(2):
        running_loss = 0.0
        for i, data in enumerate(trainloader, 0):
            inputs, labels = data
            optimizer.zero_grad()

            # fw + bw + opt
            outputs = net(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            running_loss += loss.item()
            if i % 2000 == 1999:
                print('[%d, %5d] loss: %.3f' %
                      (epoch + 1, i + 1, running_loss / 2000))
                running_loss = 0.0
    print("Training finished")

    # save net
    torch.save(net.state_dict(), MODEL_PATH)


def test_model():
    trainloader, testloader = load_data_set()
    net = MyNet()
    net.load_state_dict(torch.load(MODEL_PATH))
    correct = 0
    total = 0
    with torch.no_grad():
        for data in testloader:
            images, labels = data
            outputs = net(images)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    print('Accuracy of the network on the 10000 test images: %d %%' %
          (100 * correct / total))


def sample_image():
    trainloader, testloader = load_data_set()
    dataiter = iter(trainloader)
    images, labels = dataiter.next()
    print(' '.join('%5s' % classes[labels[j]] for j in range(4)))
    show(torchvision.utils.make_grid(images))


def test_image():
    trainloader, testloader = load_data_set()
    dataiter = iter(testloader)
    images, labels = dataiter.next()
    net = MyNet()
    net.load_state_dict(torch.load(MODEL_PATH))
    outputs = net(images)
    _, predicted = torch.max(outputs, 1)
    print("Predicted: ",
          " ".join("%5s" % classes[predicted[j]] for j in range(4)))


def to_onnx():
    net = MyNet()
    net.load_state_dict(torch.load(MODEL_PATH))
    dummy_input = torch.rand(1, 3, 32, 32)
    input_names = ['image']
    output_names = ['classLabelProbs']
    torch.onnx.export(net,
                      dummy_input,
                      'cifar_net.onnx',
                      verbose=True,
                      input_names=input_names,
                      output_names=output_names)


def to_coreml():
    model = ct.converters.onnx.convert(
        "cifar_net.onnx",
        mode="classifier",
        minimum_ios_deployment_target="13",
        image_input_names=["image"],
        predicted_feature_name="classLabel",
        class_labels=class_labels
    )
    model.save("cifar_net.mlmodel")


if __name__ == "__main__":
    # pipeline
    train_model()
    test_model()
    to_onnx()
    to_coreml()
